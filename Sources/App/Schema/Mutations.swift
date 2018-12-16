//
//  Mutations.swift
//  Async
//
//  Created by Артем Валиев on 08/12/2018.
//

import GraphQL
import Crypto
import Vapor
import Fluent

let mutationType = try! GraphQLObjectType(
    name: "Mutation",
    fields: [
        "createUser": GraphQLField(
            type: userType,
            args: CreateUserRequest.graphQLArgs,
            resolve: { _, arguments, _, eventLoopGroup, _ in
                return try createUserResolver(req: eventLoopGroup as! Request, args: arguments)
            }
        ),
        "loginUser": GraphQLField(
            type: hunanTokenType,
            args: [
                "email": GraphQLArgument(
                    type: GraphQLString,
                    description: "email of the user"
                ),
                "password": GraphQLArgument(
                    type: GraphQLString,
                    description: "password of the user"
                )
            ],
            resolve: { source, arguments, context, eventLoopGroup, info in
                let req = (eventLoopGroup as! Request)
                return try loginUserResolver(req: eventLoopGroup as! Request, arguments: arguments)
            }
        ),
        "updateUser": GraphQLField(
            type: userType,
            args: UpdateUserRequest.graphQLArgs,
            resolve: { source, arguments, context, eventLoopGroup, info in
                let req = (eventLoopGroup as! Request)
                return try UpdateUserRequest.updateUserResolver(req: eventLoopGroup as! Request, args: arguments)
            }
        ),
        "createEvent": GraphQLField(
            type: eventType,
            args: [
                "name": GraphQLArgument(
                    type: GraphQLString,
                    description: "createEvent"
                ),
            ],
            resolve: { source, arguments, context, eventLoopGroup, info in
                return try createEventResolver(req: eventLoopGroup as! Request, args: arguments)
            }
        ),
        "createGroup": GraphQLField(
            type: groupType,
            args: [
                "name": GraphQLArgument(
                    type: GraphQLString,
                    description: "name of the group"
                ),
                "description": GraphQLArgument(
                    type: GraphQLString,
                    description: "description of the group"
                ),
                "logoURL": GraphQLArgument(
                    type: GraphQLString,
                    description: "image path of the group"
                ),
                ],
            resolve: { source, arguments, context, eventLoopGroup, info in
                return try createGroupResolver(req: eventLoopGroup as! Request, args: arguments)
        }
        ),
        "subscribeToEvent": GraphQLField(
            type: eventType,
            args: [
                "eventId": GraphQLArgument(
                    type: GraphQLInt,
                    description: "subscribe to event"
                ),
                ],
            resolve: { source, arguments, context, eventLoopGroup, info in
                return try subscribeToEventResolver(req: eventLoopGroup as! Request, args: arguments)
            }
        ),
        "unsubscribeFromEvent": GraphQLField(
            type: eventType,
            args: [
                "eventId": GraphQLArgument(
                    type: GraphQLInt,
                    description: "unsubscribe to event"
                ),
                ],
            resolve: { source, arguments, context, eventLoopGroup, info in
                return try unsubscribeFromEventResolver(req: eventLoopGroup as! Request, args: arguments)
            }
        ),
    ]
)


func createUserResolver(req: Request, args: Map) throws -> Future<Any?> {
    let createUserRequest = try args.decode(type: CreateUserRequest.self)
    let hash = try BCrypt.hash(createUserRequest.password)

    return User.query(on: req).filter(\User.email == createUserRequest.email).first().flatMap { optionalUser in
        if let user = optionalUser {
            throw GraphQLError(message: "User with email \(user.email) already exist!")
        } else {
            let user = User(name: createUserRequest.name, email: createUserRequest.email, passwordHash: hash, profileImagePath: nil)
            return user.save(on: req).map { return $0 }
        }
    }
}

func loginUserResolver(req: Request, arguments: Map) throws -> Future<Any?> {
    
    let basic = BasicAuthorization(username: arguments["email"].string!,
                                   password: arguments["password"].string!)
    return User.authenticate(using: basic, verifier: BCryptDigest(), on: req).flatMap({ (user) in
        if let user = user {
            let token = try UserToken.create(userID: user.requireID())
            return token.save(on: req).map { $0 }
        } else {
            throw GraphQLError(message: "Wrong email or password")
        }
    })
}


func createEventResolver(req: Request, args: Map) throws -> Future<Any?> {
    return try getUser(on: req).flatMap { user in
        let createEventRequest = try args.decode(type: CreateEventRequest.self)
        let event = Event(title: createEventRequest.name, eventDescription: "Description", address: "Address", logoURL: nil, userID: user.id!, eventType: 0)
        return event.save(on: req).map{ $0 }
    }
}

func createGroupResolver(req: Request, args: Map) throws -> Future<Any?> {
    return try getUser(on: req).flatMap { user in
        let createGroupRequest = try args.decode(type: CreateGroupRequest.self)
        let group = Group(title: createGroupRequest.name, groupDescription: createGroupRequest.description, address: "Address", logoURL: createGroupRequest.logoURL, userID: user.id!, groupType: 0)
        return group.save(on: req).map{ $0 }
    }
}


func subscribeToEventResolver(req: Request, args: Map) throws -> Future<Any?> {
    return try getUser(on: req).flatMap { user in
        
        let request = try args.decode(type: SubscribeToEventRequest.self)
        return Event.find(request.eventId, on: req).flatMap{ event in
            if let event = event {
                return try event.subscribers.query(on: req).all().flatMap{ subs in
                    // удостоверимся, что у подписчиков данного евента уже нет текущего юзера, чтобы не дублировать запись в бд
                    guard subs.filter({ $0.id == user.id }).count == 0 else {
                        throw GraphQLError(message: "Вы уже подписаны на это событие")
                    }
                    return event.subscribers.attach(user, on: req).transform(to: event)
                }
            } else {
                throw GraphQLError(message: "Event with id: \(request.eventId) not found")
            }
        }
    }
}

func unsubscribeFromEventResolver(req: Request, args: Map) throws -> Future<Any?> {
    return try getUser(on: req).flatMap { user in
        let request = try args.decode(type: SubscribeToEventRequest.self)
        return Event.find(request.eventId, on: req).flatMap{ event in
            if let event = event {
                return event.subscribers.detach(user, on: req).transform(to: event)
            } else {
                throw GraphQLError(message: "Event with id: \(request.eventId) not found")
            }
        }
    }
}


struct SubscribeToEventRequest: Content {
    var eventId: Int
}

struct CreateUserRequest: Content {
    var name: String
    var email: String
    var password: String
    
    static var graphQLArgs: [String: GraphQLArgument] {
        get {
            return [
            "name": GraphQLArgument(type: GraphQLString, description: "name of the User"),
            "email": GraphQLArgument(type: GraphQLString, description: "email of the User"),
            "password": GraphQLArgument(type: GraphQLString, description: "password of the user")
            ]
        }
    }
}

struct UpdateUserRequest: Content {
    var name: String?
    var profileImagePath: String?
    
    static var graphQLArgs: [String: GraphQLArgument] {
        get {
            return [
                "name": GraphQLArgument(type: GraphQLString, description: "name of the User"),
                "profileImagePath": GraphQLArgument(type: GraphQLString, description: "user's profile picture")
            ]
        }
    }
    
    static func updateUserResolver(req: Request, args: Map) throws -> Future<Any?> {
        return try getUser(on: req).flatMap { user in
            let updateUserRequest = try args.decode(type: UpdateUserRequest.self)
            
            if let imagePath = updateUserRequest.profileImagePath {
                user.profileImagePath = imagePath
            }
            if let name = updateUserRequest.name {
                user.name = name
            }
            
            return user.save(on: req).map { return $0 }
        }
    }
}

struct CreateEventRequest: Content {
    var name: String
}

struct CreateGroupRequest: Content {
    var name: String
    var description: String
    var logoURL: String?
}
