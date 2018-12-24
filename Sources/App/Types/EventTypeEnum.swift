//
//  EventTypeEnum.swift
//  App
//
//  Created by Артем Валиев on 24/12/2018.
//

import GraphQL

let eventTypeEnum = try! GraphQLEnumType(
    name: "EventType",
    description: "On of the event type",
    values: [
        "roda": GraphQLEnumValue(
            value: EventType.roda,
            description: "Roda"
        ),
        "party": GraphQLEnumValue(
            value: EventType.party,
            description: "Party"
        ),
        "seminar": GraphQLEnumValue(
            value: EventType.seminar,
            description: "Seminar"
        ),
        "training": GraphQLEnumValue(
            value: EventType.training,
            description: "Training"
        ),
    ]
)
