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
            args: [
                "name": GraphQLArgument(
                    type: GraphQLString,
                    description: "name of the User"
                ),
                "email": GraphQLArgument(
                    type: GraphQLString,
                    description: "email of the User"
                ),
                "password": GraphQLArgument(
                    type: GraphQLString,
                    description: "password of the user"
                )
            ],
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


func createUserResolver(req: Request, args: Map) throws -> EventLoopFuture<Any?> {
    let createUserRequest = try args.decode(type: CreateUserRequest.self)
    let hash = try BCrypt.hash(createUserRequest.password)

    return User.query(on: req).filter(\User.email == createUserRequest.email).first().flatMap { optionalUser in
        if let user = optionalUser {
            throw MyError(description: "User with email \(user.email) already exist")
        } else {
            let user = User(name: createUserRequest.name, email: createUserRequest.email, passwordHash: hash)
            return user.save(on: req).map { return $0 }
        }
    }
}

func loginUserResolver(req: Request, arguments: Map) throws -> EventLoopFuture<Any?> {
    
    let basic = BasicAuthorization(username: arguments["email"].string!,
                                   password: arguments["password"].string!)
    return User.authenticate(using: basic, verifier: BCryptDigest(), on: req).flatMap({ (user) in
        if let user = user {
            let token = try UserToken.create(userID: user.requireID())
            return token.save(on: req).map { $0 }
        } else {
            throw MyError(description: "Wrong email or password")
        }
    })
}


func createEventResolver(req: Request, args: Map) throws -> EventLoopFuture<Any?> {
    return try getUser(on: req).flatMap { user in
        let createEventRequest = try args.decode(type: CreateEventRequest.self)
        let event = Event(title: createEventRequest.name, eventDescription: "Description", address: "Address", logoURL: nil, userID: user.id!, eventType: 0)
        return event.save(on: req).map{ $0 }
    }
}

func subscribeToEventResolver(req: Request, args: Map) throws -> EventLoopFuture<Any?> {
    return try getUser(on: req).flatMap { user in
        
        let request = try args.decode(type: SubscribeToEventRequest.self)
        return Event.find(request.eventId, on: req).flatMap{ event in
            if let event = event {
                return try event.subscribers.query(on: req).all().flatMap{ subs in
                    // удостоверимся, что у подписчиков данного евента уже нет текущего юзера, чтобы не дублировать запись в бд
                    guard subs.filter({ $0.id == user.id }).count == 0 else {
                        throw MyError(description: "Вы уже подписаны на это событие")
                    }
                    return event.subscribers.attach(user, on: req).transform(to: event)
                }
            } else {
                throw MyError(description: "Event with id: \(request.eventId) not found")
            }
        }
    }
}

func unsubscribeFromEventResolver(req: Request, args: Map) throws -> EventLoopFuture<Any?> {
    return try getUser(on: req).flatMap { user in
        let request = try args.decode(type: SubscribeToEventRequest.self)
        return Event.find(request.eventId, on: req).flatMap{ event in
            if let event = event {
                return event.subscribers.detach(user, on: req).transform(to: event)
            } else {
                throw MyError(description: "Event with id: \(request.eventId) not found")
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
}

struct CreateEventRequest: Content {
    var name: String
}
