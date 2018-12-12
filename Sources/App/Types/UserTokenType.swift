//
//  UserTokenType.swift
//  Async
//
//  Created by Артем Валиев on 08/12/2018.
//
import GraphQL
import Vapor

let hunanTokenType = try! GraphQLObjectType(
    name: "UserToken",
    description: "User token",
    fields: [
        "id": GraphQLField(
            type: GraphQLNonNull(GraphQLInt),
            description: "The id of the user."
        ),
        "string": GraphQLField(
            type: GraphQLString,
            description: "Token"
        ),
        "expiresAt": GraphQLField(
            type: GraphQLString,
            description: "expiresAt",
            resolve: { userToken, _, _, eventLoopGroup, _ in
                return tokenDateResolver(eventLoopGroup: eventLoopGroup, userToken: userToken)
            }
        ),
        "user": GraphQLField(
            type: GraphQLTypeReference("User"),
            description: "user for token",
            resolve: { userToken, _, _, eventLoopGroup, _ in
                return tokenUserResolver(eventLoopGroup: eventLoopGroup, userToken: userToken)
            }
        ),
    ],
    isTypeOf: { source, _, _ in
        source is UserToken
    }
)


func tokenDateResolver(eventLoopGroup: EventLoopGroup, userToken: Any) -> Future<Any?> {
    var date: String?
    if let userToken = userToken as? UserToken, let expiresAt = userToken.expiresAt {
        date = dateFormatter.string(from: expiresAt)
    }
    return eventLoopGroup.next().newSucceededFuture(result: date)
}

func tokenUserResolver(eventLoopGroup: EventLoopGroup, userToken: Any) -> Future<Any?> {
    return User.find((userToken as! UserToken).userID, on: eventLoopGroup as! Request).map { $0 }
}
