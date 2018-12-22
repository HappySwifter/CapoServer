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
    var description: String?
    var address: String?
    var logoURL: String?
    var eventType: String?
    
    static var args: [String: GraphQLArgument] {
        get {
            return ["name": GraphQLArgument(type: GraphQLNonNull(GraphQLString), description: "name of the event"),
                    "description": GraphQLArgument(type: GraphQLString, description: "description of the event"),
                    "address": GraphQLArgument(type: GraphQLString, description: "address of the event"),
                    "logoURL": GraphQLArgument(type: GraphQLString, description: "image path of the event"),
                    "eventType": GraphQLArgument(type: eventTypeEnum, description: "type of the event")
            ]
        }
    }
    
    static func resolver(req: Request, args: Map) throws -> Future<Any?> {
        return try getUser(on: req).flatMap { user in
            let request = try args.decode(type: CreateEvent.self)
            print(request.eventType)
            let event = Event(title: request.name,
                              eventDescription: request.description,
                              address: request.address,
                              logoURL: request.logoURL,
                              userID: user.id!,
                              eventType: request.eventType)
            return event.save(on: req).map{ $0 }
        }
    }
}
