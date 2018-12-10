//
//  GroupUserPivot.swift
//  App
//
//  Created by Артем Валиев on 25/08/2018.
//

import Foundation
import FluentMySQL
import Vapor

final class GroupUserPivot: MySQLUUIDPivot, ModifiablePivot {
    
    var id: UUID?
    var groupID: Group.ID
    var userID: User.ID
    
    typealias Left = Group
    typealias Right = User
    static let leftIDKey: LeftIDKey = \.groupID
    static let rightIDKey: RightIDKey = \.userID
    
    init(_ group: Group, _ user: User) throws {
        self.groupID = try group.requireID()
        self.userID = try user.requireID()
    }
}

extension GroupUserPivot: Migration {
    static func prepare(on conn: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.create(self, on: conn) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.groupID, to: \Group.id, onDelete: .cascade)
            builder.reference(from: \.userID, to: \User.id, onDelete: .cascade)
        }
    }
    
    //    static func prepare(on conn: MySQLConnection) -> Future<Void> {
    //        return MySQLDatabase.create(User.self, on: conn) { builder in
    //            builder.field(for: \.id, isIdentifier: true)
    //            builder.field(for: \.name)
    //            builder.field(for: \.email)
    //            builder.field(for: \.passwordHash)
    //            builder.unique(on: \.email)
    //        }
    //    }
}
