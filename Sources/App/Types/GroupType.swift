//
//  GroupType.swift
//  App
//
//  Created by Артем Валиев on 10/12/2018.
//

import GraphQL
import Vapor

let groupType = try! GraphQLObjectType(
    name: "Group",
    description: "Group",
    fields: [
        "id": GraphQLField(
            type: GraphQLNonNull(GraphQLString),
            description: "The id of the user."
        ),
        "title": GraphQLField(
            type: GraphQLString,
            description: "title"
        ),
        "groupDescription": GraphQLField(
            type: GraphQLString,
            description: "groupDescription"
        ),
        "logoURL": GraphQLField(
            type: GraphQLString,
            description: "logoURL"
        ),
        "subscribers": GraphQLField(
            type: GraphQLList(GraphQLTypeReference("User")),
            description: "subscribers",
            resolve: { group, _, _, eventLoopGroup, _ in
                return try groupSubscribersResolver(eventLoopGroup: eventLoopGroup, group: group)
            }
        ),
        "owner": GraphQLField(
            type: GraphQLTypeReference("User"),
            description: "The group owner",
            resolve: { group, _, _, eventLoopGroup, _ in
                return try groupOwnerResolver(eventLoopGroup: eventLoopGroup, group: group)
            }
        ),
    ],
    isTypeOf: { source, _, _ in
        source is Group
    }
)


func groupOwnerResolver(eventLoopGroup: EventLoopGroup, group: Any) throws -> Future<Any?> {
    if let group = group as? Group, let req = eventLoopGroup as? Request {
        let userID = group.owner.parentID
        return User.find(userID, on: req).map { user in
            return user
        }
    } else {
        throw MyError(description: "Ошибка сервера")
    }
}

func groupSubscribersResolver(eventLoopGroup: EventLoopGroup, group: Any) throws -> Future<Any?> {
    let group = group as! Group
    let req = eventLoopGroup as! Request
    return try group.subscribers.query(on: req).all().map{ $0 }
}
