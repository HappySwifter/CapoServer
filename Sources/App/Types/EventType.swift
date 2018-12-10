//
//  EventSchema.swift
//  Async
//
//  Created by Артем Валиев on 08/12/2018.
//

import GraphQL
import Vapor

let eventType = try! GraphQLObjectType(
    name: "Event",
    description: "Events",
    fields: [
        "id": GraphQLField(
            type: GraphQLNonNull(GraphQLString),
            description: "The id of the user."
        ),
        "title": GraphQLField(
            type: GraphQLString,
            description: "title"
        ),
        "eventDescription": GraphQLField(
            type: GraphQLString,
            description: "eventDescription"
        ),
        "logoURL": GraphQLField(
            type: GraphQLString,
            description: "logoURL"
        ),
        "subscribers": GraphQLField(
            type: GraphQLList(GraphQLTypeReference("User")),
            description: "subscribers",
            resolve: { event, _, _, eventLoopGroup, _ in
                return try eventSubscribersResolver(eventLoopGroup: eventLoopGroup, event: event)
            }
        ),
        "owner": GraphQLField(
            type: GraphQLTypeReference("User"),
            description: "The event owner",
            resolve: { event, _, _, eventLoopGroup, _ in
                return try eventOwnerResolver(eventLoopGroup: eventLoopGroup, event: event)
            }
        ),
    ],
    isTypeOf: { source, _, _ in
        source is Event
}
)


func eventOwnerResolver(eventLoopGroup: EventLoopGroup, event: Any) throws -> Future<Any?> {
    if let event = event as? Event, let req = eventLoopGroup as? Request {
        let userID = event.user.parentID
        return User.find(userID, on: req).map { user in
            return user
        }
    } else {
        throw MyError(description: "Ошибка сервера")
    }
}

func eventSubscribersResolver(eventLoopGroup: EventLoopGroup, event: Any) throws -> Future<Any?> {
    let event = event as! Event
    let req = eventLoopGroup as! Request
    return try event.subscribers.query(on: req).all().map{ $0 }
}
