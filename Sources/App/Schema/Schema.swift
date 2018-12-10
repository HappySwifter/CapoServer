import GraphQL
import Vapor
import Fluent

var dateFormatter: DateFormatter {
    get {
        let form = DateFormatter()
        form.dateFormat = "DD MMMM YYYY"
        return form
    }
}


func getUser(on req: Request) throws -> EventLoopFuture<User> {
    guard let bearer = req.http.headers["Authorization"].first,
        let range = bearer.range(of: "Bearer ") else {
        throw MyError(description: "Invalid token")
    }
    let token = bearer[range.upperBound...]
    return UserToken.query(on: req).filter(\UserToken.string == String(token)).first().flatMap{ (userToken) in
        if let userToken = userToken {
            return userToken.user.get(on: req)
        } else {
            throw MyError(description: "Invalid token")
        }
    }
}

public let starWarsSchema = try! GraphQLSchema(
    query: queryType,
    mutation: mutationType,
    types: [hunanTokenType, userType, eventType]
)


extension User : MapFallibleRepresentable {}
extension UserToken : MapFallibleRepresentable {}
extension Event : MapFallibleRepresentable {}
