//
//  LoginUser.swift
//  App
//
//  Created by Артем Валиев on 17/12/2018.
//

import GraphQL
import Vapor
import Fluent
import Crypto

struct LoginUser {
    static var args: [String: GraphQLArgument] {
        get {
            return [
                "email": GraphQLArgument(type: GraphQLNonNull(GraphQLString), description: "email of the user"),
                "password": GraphQLArgument(type: GraphQLNonNull(GraphQLString), description: "password of the user")
            ]
        }
    }
    
    static func resolver(req: Request, arguments: Map) throws -> Future<Any?> {
        
        let basic = BasicAuthorization(username: arguments["email"].string!,
                                       password: arguments["password"].string!)
        return User.authenticate(using: basic, verifier: BCryptDigest(), on: req).flatMap({ (user) in
            if let user = user {
                let token = try UserToken.create(userID: user.requireID())
                return token.save(on: req).map { $0 }
            } else {
                throw GraphQLError(message: "Wrong email or password")
            }
        })
    }
}
