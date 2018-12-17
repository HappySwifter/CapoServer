//
//  UpdateUser.swift
//  App
//
//  Created by Артем Валиев on 17/12/2018.
//

import GraphQL
import Vapor


struct UpdateUser: Content {
    var name: String?
    var profileImagePath: String?
    
    static var args: [String: GraphQLArgument] {
        get {
            return [
                "name": GraphQLArgument(type: GraphQLString, description: "name of the User"),
                "profileImagePath": GraphQLArgument(type: GraphQLString, description: "user's profile picture")
            ]
        }
    }
    
    static func resolver(req: Request, args: Map) throws -> Future<Any?> {
        return try getUser(on: req).flatMap { user in
            let updateUserRequest = try args.decode(type: UpdateUser.self)
            
            if let imagePath = updateUserRequest.profileImagePath {
                user.profileImagePath = imagePath
            }
            if let name = updateUserRequest.name {
                user.name = name
            }
            
            return user.save(on: req).map { return $0 }
        }
    }
}
