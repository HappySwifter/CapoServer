//
//  CreateUser.swift
//  App
//
//  Created by Артем Валиев on 17/12/2018.
//

import Foundation
import GraphQL
import Vapor
import Fluent
import Crypto


struct CreateUser: Content {
    var name: String
    var email: String
    var password: String
    
    static var args: [String: GraphQLArgument] {
        get {
            return [
                "name": GraphQLArgument(type: GraphQLNonNull(GraphQLString), description: "name of the user"),
                "email": GraphQLArgument(type: GraphQLNonNull(GraphQLString), description: "email of the user"),
                "password": GraphQLArgument(type: GraphQLNonNull(GraphQLString), description: "password of the user")
            ]
        }
    }
    
    static func resolver(req: Request, args: Map) throws -> Future<Any?> {
        let createUserRequest = try args.decode(type: CreateUser.self)
        let hash = try BCrypt.hash(createUserRequest.password)
        
        return User.query(on: req).filter(\User.email == createUserRequest.email).first().flatMap { optionalUser in
            if let user = optionalUser {
                throw GraphQLError(message: "User with email \(user.email) already exist!")
            } else {
                let user = User(name: createUserRequest.name, email: createUserRequest.email, passwordHash: hash, profileImagePath: nil)
                return user.save(on: req).map { return $0 }
            }
        }
    }
}
