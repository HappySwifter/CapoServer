//
//  EventUserPivot.swift
//  App
//
//  Created by Артем Валиев on 25/08/2018.
//

import Foundation
import FluentSQLite
import Vapor

final class EventUserPivot: SQLiteUUIDPivot, ModifiablePivot {
    
    var id: UUID?
    var eventID: Event.ID
    var userID: User.ID
    
    typealias Left = Event
    typealias Right = User
    static let leftIDKey: LeftIDKey = \.eventID
    static let rightIDKey: RightIDKey = \.userID
    
    init(_ event: Event, _ user: User) throws {
        self.eventID = try event.requireID()
        self.userID = try user.requireID()
    }
}

extension EventUserPivot: Migration {
    static func prepare(on conn: SQLiteConnection) -> Future<Void> {
        return SQLiteDatabase.create(self, on: conn) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.eventID, to: \Event.id, onDelete: .cascade)
            builder.reference(from: \.userID, to: \User.id, onDelete: .cascade)
        }
    }
    
    //    static func prepare(on conn: SQLiteConnection) -> Future<Void> {
    //        return SQLiteDatabase.create(User.self, on: conn) { builder in
    //            builder.field(for: \.id, isIdentifier: true)
    //            builder.field(for: \.name)
    //            builder.field(for: \.email)
    //            builder.field(for: \.passwordHash)
    //            builder.unique(on: \.email)
    //        }
    //    }
}
