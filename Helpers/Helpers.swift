//
//  Helpers.swift
//  App
//
//  Created by Артем Валиев on 10/12/2018.
//

import Foundation
import GraphQL


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
