//
//  UserType.swift
//  App
//
//  Created by Артем Валиев on 10/12/2018.
//

import GraphQL
import Vapor

let userType = try! GraphQLObjectType(
    name: "User",
    description: "A humanoid creature in the Star Wars universe.",
    fields: [
        "id": GraphQLField(
            type: GraphQLNonNull(GraphQLString),
            description: "The id of the user."
        ),
        "name": GraphQLField(
            type: GraphQLString,
            description: "The name of the user."
        ),
        "email": GraphQLField(
            type: GraphQLString,
            description: "Email of the user, or null if unknown."
        ),
        ],
    isTypeOf: { source, _, _ in
        source is User
}
)
