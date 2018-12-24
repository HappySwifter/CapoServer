import GraphQL

public let starWarsSchema = try! GraphQLSchema(
    query: queryType,
    mutation: mutationType,
    types: [hunanTokenType, userType, eventType, groupType]
)


extension User : MapFallibleRepresentable {}
extension UserToken : MapFallibleRepresentable {}
extension Event : MapFallibleRepresentable {}
extension Group : MapFallibleRepresentable {}

extension EventType : MapRepresentable {
    var map: Map {
        return rawValue.map
    }
}
