import FluentSQLite
import Vapor
import GraphQL



enum EventType: Int {
    case roda = 0
    case openLesson
    case seminar
    case party
}

/// A single entry of a event list.
final class Event: SQLiteModel {
    /// The unique identifier for this `Event`.
    var id: Int?
    
    /// A title describing what this `Event` entails.
    var title: String
    var eventDescription: String?
    var address: String?
    var logoURL: String?
    /// Reference to user that owns this event.
    var userID: User.ID
    
    var eventType: Int?
    /// Creates a new `Event`.
    init(id: Int? = nil, title: String, eventDescription: String, address: String, logoURL: String?, userID: User.ID, eventType: Int) {
        self.id = id
        self.title = title
        self.eventDescription = eventDescription
        self.address = address
        self.logoURL = logoURL
        self.userID = userID
        self.eventType = eventType
    }
    
    
}

extension Event {
    /// Fluent relation to user that owns this event.
    var user: Parent<Event, User> {
        return parent(\.userID)
    }
    
    var subscribers: Siblings<Event, User, EventUserPivot> {
        return siblings()
    }
}

/// Allows `Event` to be used as a Fluent migration.
extension Event: Migration {
    static func prepare(on conn: SQLiteConnection) -> Future<Void> {
        return SQLiteDatabase.create(Event.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.title)
            builder.field(for: \.userID)
            builder.reference(from: \.userID, to: \User.id)
            builder.field(for: \.eventDescription)
            builder.field(for: \.eventType)
            builder.field(for: \.address)
            //            builder.field(for: \.address, type: .text, .default(.literal(.boolean(.true))))
        }
    }
}

/// Allows `Event` to be encoded to and decoded from HTTP messages.
extension Event: Content { }

/// Allows `Event` to be used as a dynamic parameter in route definitions.
extension Event: Parameter { }




struct AddEventType: SQLiteMigration {
    static func revert(on conn: SQLiteConnection) -> Future<Void> {
        return SQLiteDatabase.update(Event.self, on: conn, closure: { (builder) in
            builder.deleteField(for: \.logoURL)
            
        })
    }
    
    static func prepare(on conn: SQLiteConnection) -> Future<Void> {
        return SQLiteDatabase.update(Event.self, on: conn, closure: { (builder) in
            builder.field(for: \.logoURL)
        })
    }
}

struct EventTypeCleanup: SQLiteMigration {
    static func revert(on conn: SQLiteConnection) -> EventLoopFuture<Void> {
        return conn.future(())
    }
    
    static func prepare(on conn: SQLiteConnection) -> Future<Void> {
        return Event.query(on: conn).delete()
    }
}
