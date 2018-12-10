import FluentSQLite
import Vapor
import Authentication


final class User: SQLiteModel {
    var id: Int?
    
    let name: String
    /// User's email address.
    var email: String
    
    /// BCrypt hash of the user's password.
    var passwordHash: String
    
    /// Creates a new `User`.
    init(id: Int? = nil, name: String, email: String, passwordHash: String) {
        self.id = id
        self.name = name
        self.email = email
        self.passwordHash = passwordHash
    }
}



extension User: Migration {
    /// See `Migration`.
    static func prepare(on conn: SQLiteConnection) -> Future<Void> {
        return SQLiteDatabase.create(User.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.name)
            builder.field(for: \.email)
            builder.field(for: \.passwordHash)
            builder.unique(on: \.email)
        }
    }
}

extension User {
    var events: Children<User, Event> {
        return children(\Event.userID)
    }
    var subscribedEvents: Siblings<User, Event, EventUserPivot> {
        return siblings()
    }
    
//    var groups: Children<User, Group> {
//        return children(\Group.userID)
//    }
//    var subscribedGroups: Siblings<User, Group, GroupUserPivot> {
//        return siblings()
//    }
}

/// Allows users to be verified by basic / password auth middleware.
extension User: PasswordAuthenticatable {
    /// See `PasswordAuthenticatable`.
    static var usernameKey: WritableKeyPath<User, String> {
        return \.email
    }
    
    /// See `PasswordAuthenticatable`.
    static var passwordKey: WritableKeyPath<User, String> {
        return \.passwordHash
    }
}

/// Allows users to be verified by bearer / token auth middleware.
extension User: TokenAuthenticatable {
    /// See `TokenAuthenticatable`.
    typealias TokenType = UserToken
}

/// Allows `User` to be encoded to and decoded from HTTP messages.
extension User: Content { }

/// Allows `User` to be used as a dynamic parameter in route definitions.
extension User: Parameter { }
