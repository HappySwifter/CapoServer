//
//  CreateGroup.swift
//  App
//
//  Created by Артем Валиев on 17/12/2018.
//

import GraphQL
import Vapor

struct CreateGroup: Content {
    var name: String
    var description: String?
    var address: String?
    var logoURL: String?
    
    static var args: [String: GraphQLArgument] {
        get {
            return [
                "name": GraphQLArgument(type: GraphQLNonNull(GraphQLString), description: "name of the group"),
                "description": GraphQLArgument(type: GraphQLString, description: "description of the group"),
                "address": GraphQLArgument(type: GraphQLString, description: "address of the group"),
                "logoURL": GraphQLArgument(type: GraphQLString, description: "group's image")
            ]
        }
    }
    
    static func resolver(req: Request, args: Map) throws -> Future<Any?> {
        return try getUser(on: req).flatMap { user in
            let createGroupRequest = try args.decode(type: CreateGroup.self)
            let group = Group(title: createGroupRequest.name,
                              groupDescription: createGroupRequest.description,
                              address: createGroupRequest.address,
                              logoURL: createGroupRequest.logoURL,
                              userID: user.id!,
                              groupType: 0)
            return group.save(on: req).map{ $0 }
        }
    }
}
