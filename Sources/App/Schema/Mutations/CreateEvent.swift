//
//  CreateEvent.swift
//  App
//
//  Created by Артем Валиев on 17/12/2018.
//

import GraphQL
import Vapor

struct CreateEvent: Content {
    var name: String
    
    static var args: [String: GraphQLArgument] {
        get {
            return ["name": GraphQLArgument(type: GraphQLString, description: "name of the group"),
                    "description": GraphQLArgument(type: GraphQLString, description: "description of the group"),
                    "logoURL": GraphQLArgument(type: GraphQLString, description: "image path of the group")
            ]
        }
    }
    
    static func resolver(req: Request, args: Map) throws -> Future<Any?> {
        return try getUser(on: req).flatMap { user in
            let createEventRequest = try args.decode(type: CreateEvent.self)
            let event = Event(title: createEventRequest.name, eventDescription: "Description", address: "Address", logoURL: nil, userID: user.id!, eventType: 0)
            return event.save(on: req).map{ $0 }
        }
    }
}
