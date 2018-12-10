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
            description: "The name of the user."
        ),
        "eventDescription": GraphQLField(
            type: GraphQLString,
            description: "Email of the user, or null if unknown."
        ),
        "logoURL": GraphQLField(
            type: GraphQLString,
            description: "Email of the user, or null if unknown."
        ),
        "subscribers": GraphQLField(
            type: GraphQLList(GraphQLTypeReference("User")),
            description: "The friends of the character, or an empty list if they have none.",
            resolve: { event, _, _, eventLoopGroup, _ in
                return try eventSubscribersResolver(eventLoopGroup: eventLoopGroup, event: event)
            }
        ),
        "owner": GraphQLField(
            type: GraphQLTypeReference("User"),
            description: "The friends of the character, or an empty list if they have none.",
            resolve: { event, _, _, eventLoopGroup, _ in
                return try eventOwnerResolver(eventLoopGroup: eventLoopGroup, event: event)
            }
        ),
    ],
    isTypeOf: { source, _, _ in
        source is Event
}
)


func eventOwnerResolver(eventLoopGroup: EventLoopGroup, event: Any) throws -> EventLoopFuture<Any?> {
    if let event = event as? Event, let req = eventLoopGroup as? Request {
        let userID = event.user.parentID
        return User.find(userID, on: req).map { user in
            return user
        }
    } else {
        throw MyError(description: "ошибка епть")
    }
}

func eventSubscribersResolver(eventLoopGroup: EventLoopGroup, event: Any) throws -> EventLoopFuture<Any?> {
    let event = event as! Event
    let req = eventLoopGroup as! Request
    return try event.subscribers.query(on: req).all().map{ $0 }
}
