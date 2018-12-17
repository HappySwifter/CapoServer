//
//  UnSubscribeFromEvent.swift
//  App
//
//  Created by Артем Валиев on 17/12/2018.
//

import GraphQL
import Vapor

struct UnsubscribeFromEvent: Content {
    var eventId: Int
    
    static var args: [String: GraphQLArgument] {
        get {
            return [
                "eventId": GraphQLArgument(type: GraphQLInt, description: "unsubscribe from event")
            ]
        }
    }
    
    static func resolver(req: Request, args: Map) throws -> Future<Any?> {
        return try getUser(on: req).flatMap { user in
            let request = try args.decode(type: UnsubscribeFromEvent.self)
            return Event.find(request.eventId, on: req).flatMap{ event in
                if let event = event {
                    return event.subscribers.detach(user, on: req).transform(to: event)
                } else {
                    throw GraphQLError(message: "Event with id: \(request.eventId) not found")
                }
            }
        }
    }
}
