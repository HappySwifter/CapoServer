//
//  SubscribeToEvent.swift
//  App
//
//  Created by Артем Валиев on 17/12/2018.
//


import GraphQL
import Vapor

struct SubscribeToEvent: Content {
    var eventId: Int
    
    static var args: [String: GraphQLArgument] {
        get {
            return [
                "eventId": GraphQLArgument(type: GraphQLInt, description: "subscribe to event")
            ]
        }
    }
    
    static func resolver(req: Request, args: Map) throws -> Future<Any?> {
        return try getUser(on: req).flatMap { user in
            
            let request = try args.decode(type: SubscribeToEvent.self)
            return Event.find(request.eventId, on: req).flatMap{ event in
                if let event = event {
                    return try event.subscribers.query(on: req).all().flatMap{ subs in
                        // удостоверимся, что у подписчиков данного евента уже нет текущего юзера, чтобы не дублировать запись в бд
                        guard subs.filter({ $0.id == user.id }).count == 0 else {
                            throw GraphQLError(message: "Вы уже подписаны на это событие")
                        }
                        return event.subscribers.attach(user, on: req).transform(to: event)
                    }
                } else {
                    throw GraphQLError(message: "Event with id: \(request.eventId) not found")
                }
            }
        }
    }
}
