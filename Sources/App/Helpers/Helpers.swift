//
//  Helpers.swift
//  App
//
//  Created by Артем Валиев on 10/12/2018.
//

import Foundation
import GraphQL
import Fluent
import Vapor

struct MyError: Error, CustomStringConvertible {
    let description: String
}

extension Map {
    func decode<T: Codable>(type: T.Type) throws -> T  {
        do {
            if let jsonData = self.description.data(using: .utf8) {
                return try JSONDecoder().decode(type, from: jsonData)
            } else {
                throw MyError(description: "wrong format")
            }
        } catch {
            throw MyError(description: "\(error)")
        }
        
    }
}

var dateFormatter: DateFormatter {
    get {
        let form = DateFormatter()
        form.dateFormat = "DD MMMM YYYY"
        return form
    }
}


func getUser(on req: Request) throws -> EventLoopFuture<User> {
    guard let bearer = req.http.headers["Authorization"].first,
        let range = bearer.range(of: "Bearer ") else {
            throw MyError(description: "Invalid token")
    }
    let token = bearer[range.upperBound...]
    return UserToken.query(on: req).filter(\UserToken.string == String(token)).first().flatMap{ (userToken) in
        if let userToken = userToken {
            return userToken.user.get(on: req)
        } else {
            throw MyError(description: "Invalid token")
        }
    }
}
