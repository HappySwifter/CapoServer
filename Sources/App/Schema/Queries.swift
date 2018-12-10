//
//  Queries.swift
//  Async
//
//  Created by Артем Валиев on 08/12/2018.
//

import GraphQL
import Vapor

let queryType = try! GraphQLObjectType(
    name: "Query",
    fields: [
        "getUser": GraphQLField(
            type: userType,
            args: [
                "id": GraphQLArgument(
                    type: GraphQLNonNull(GraphQLInt),
                    description: "id of the user"
                )
            ],
            resolve: { _, arguments, _, eventLoopGroup, _ in
                return getUserByIdResolver(req: eventLoopGroup as! Request, args: arguments)
            }
        ),
        "getAllEvents": GraphQLField(
            type: GraphQLList(eventType),
            resolve: { _, arguments, _, eventLoopGroup, _ in
                return getAllEventsResiolver(req: eventLoopGroup as! Request)
            }
        ),
    ]
)


func getUserByIdResolver(req: Request, args: Map) -> EventLoopFuture<Any?> {
    return User.find(args["id"].int!, on: req).map { $0 }
}

func getAllEventsResiolver(req: Request) -> EventLoopFuture<Any?> {
    return Event.query(on: req).all().map { $0 }
}
