//
//  Mutations.swift
//  Async
//
//  Created by Артем Валиев on 08/12/2018.
//

import GraphQL
import Vapor

let mutationType = try! GraphQLObjectType(
    name: "Mutation",
    fields: [
        "createUser": GraphQLField(
            type: userType,
            args: CreateUser.args,
            resolve: { _, arguments, _, eventLoopGroup, _ in
                return try CreateUser.resolver(req: eventLoopGroup as! Request, args: arguments)
            }
        ),
        "loginUser": GraphQLField(
            type: hunanTokenType,
            args: LoginUser.args,
            resolve: { _, arguments, _, eventLoopGroup, _ in
                return try LoginUser.resolver(req: eventLoopGroup as! Request, arguments: arguments)
            }
        ),
        "updateUser": GraphQLField(
            type: userType,
            args: UpdateUser.args,
            resolve: { _, arguments, _, eventLoopGroup, _ in
                return try UpdateUser.resolver(req: eventLoopGroup as! Request, args: arguments)
            }
        ),
        "createEvent": GraphQLField(
            type: eventType,
            args: CreateEvent.args,
            resolve: { _, arguments, _, eventLoopGroup, _ in
                return try CreateEvent.resolver(req: eventLoopGroup as! Request, args: arguments)
            }
        ),
        "createGroup": GraphQLField(
            type: groupType,
            args: CreateOrUpdateGroup.args,
            resolve: { _, arguments, _, eventLoopGroup, _ in
                return try CreateOrUpdateGroup.resolver(req: eventLoopGroup as! Request, args: arguments)
        }
        ),
        "subscribeToEvent": GraphQLField(
            type: eventType,
            args: SubscribeToEvent.args,
            resolve: { _, arguments, _, eventLoopGroup, _ in
                return try SubscribeToEvent.resolver(req: eventLoopGroup as! Request, args: arguments)
            }
        ),
        "unsubscribeFromEvent": GraphQLField(
            type: eventType,
            args: UnsubscribeFromEvent.args,
            resolve: { _, arguments, _, eventLoopGroup, _ in
                return try UnsubscribeFromEvent.resolver(req: eventLoopGroup as! Request, args: arguments)
            }
        ),
    ]
)
