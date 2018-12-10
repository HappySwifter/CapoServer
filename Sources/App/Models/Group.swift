import FluentMySQL
import Vapor
import GraphQL



enum GroupType: Int {
    case roda = 0
    case openLesson
    case seminar
    case party
}

/// A single entry of a Group list.
final class Group: MySQLModel {
    /// The unique identifier for this `Group`.
    var id: Int?
    
    /// A title describing what this `Group` entails.
    var title: String
    var groupDescription: String?
    var address: String?
    var logoURL: String?
    /// Reference to user that owns this group.
    var userID: User.ID
    
    var groupType: Int?
    /// Creates a new `Group`.
    init(id: Int? = nil, title: String, groupDescription: String, address: String, logoURL: String?, userID: User.ID, groupType: Int) {
        self.id = id
        self.title = title
        self.groupDescription = groupDescription
        self.address = address
        self.logoURL = logoURL
        self.userID = userID
        self.groupType = groupType
    }
    
    
}

extension Group {
    /// Fluent relation to user that owns this group.
    var owner: Parent<Group, User> {
        return parent(\.userID)
    }
    
    var subscribers: Siblings<Group, User, GroupUserPivot> {
        return siblings()
    }
}

/// Allows `Group` to be used as a Fluent migration.
extension Group: Migration {
    static func prepare(on conn: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.create(Group.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.title)
            builder.field(for: \.logoURL)
            builder.field(for: \.userID)
            builder.reference(from: \.userID, to: \User.id)
            builder.field(for: \.groupDescription)
            builder.field(for: \.groupType)
            builder.field(for: \.address)
            //            builder.field(for: \.address, type: .text, .default(.literal(.boolean(.true))))
        }
    }
}

/// Allows `Group` to be encoded to and decoded from HTTP messages.
extension Group: Content { }

/// Allows `Group` to be used as a dynamic parameter in route definitions.
extension Group: Parameter { }




struct AddGroupType: MySQLMigration {
    static func revert(on conn: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.update(Group.self, on: conn, closure: { (builder) in
            builder.deleteField(for: \.logoURL)
            
        })
    }
    
    static func prepare(on conn: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.update(Group.self, on: conn, closure: { (builder) in
            builder.field(for: \.logoURL)
        })
    }
}

struct GroupTypeCleanup: MySQLMigration {
    static func revert(on conn: MySQLConnection) -> Future<Void> {
        return conn.future(())
    }
    
    static func prepare(on conn: MySQLConnection) -> Future<Void> {
        return Group.query(on: conn).delete()
    }
}
