//
//  CreateGroup.swift
//  App
//
//  Created by Артем Валиев on 17/12/2018.
//

import GraphQL
import Vapor

struct CreateOrUpdateGroup: Content {
    var id: Int?
    var name: String
    var description: String?
    var address: String?
    var logoURL: String?
    
    static var args: [String: GraphQLArgument] {
        get {
            return [
                "id": GraphQLArgument(type: GraphQLInt, description: "id of the group if you want to update"),
                "name": GraphQLArgument(type: GraphQLNonNull(GraphQLString), description: "name of the group"),
                "description": GraphQLArgument(type: GraphQLString, description: "description of the group"),
                "address": GraphQLArgument(type: GraphQLString, description: "address of the group"),
                "logoURL": GraphQLArgument(type: GraphQLString, description: "group's image")
            ]
        }
    }
    
    static func resolver(req: Request, args: Map) throws -> Future<Any?> {
        return try getUser(on: req).flatMap { user in
            let request = try args.decode(type: CreateOrUpdateGroup.self)
            let group = Group(id: request.id,
                              title: request.name,
                              groupDescription: request.description,
                              address: request.address,
                              logoURL: request.logoURL,
                              userID: user.id!,
                              groupType: 0)
            
            if let groupId = request.id {
                return Group.find(groupId, on: req).flatMap { dbGroup in
                    if let dbGroup = dbGroup {
                        if dbGroup.owner.parentID == user.id {
                            return group.save(on: req).map{ $0 }
                        } else {
                            throw GraphQLError(message: "Access denied. Can't modify group")
                        }
                    } else {
                        throw GraphQLError(message: "no such group with id: \(groupId)")
                    }
                }
            } else {
                return group.save(on: req).map{ $0 }
            }
        }
    }
}
