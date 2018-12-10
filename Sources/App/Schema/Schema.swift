import GraphQL

public let starWarsSchema = try! GraphQLSchema(
    query: queryType,
    mutation: mutationType,
    types: [hunanTokenType, userType, eventType]
)


extension User : MapFallibleRepresentable {}
extension UserToken : MapFallibleRepresentable {}
extension Event : MapFallibleRepresentable {}
