import FluentMySQL
import Vapor
import VaporGraphQL
import Authentication

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    
    services.register(NIOServerConfig.default(maxBodySize: 5_000_000))
    try services.register(FluentMySQLProvider())

    try services.register(AuthenticationProvider())
    
    let httpGraphQL = HTTPGraphQL() { req -> ExecutionContext in
        return (
            schema: starWarsSchema,
            rootValue: [:],
            context: req
        )
    }
    services.register(httpGraphQL, as: GraphQLService.self)
    
    /// Register routes to the router
    let router = EngineRouter.default()
    let graphQLRouteCollection = GraphQLRouteCollection(enableGraphiQL: true)
    try graphQLRouteCollection.boot(router: router)
    try routes(router)
    services.register(router, as: Router.self)
    
    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    
    services.register(middlewares)

    // Register the configured database to the database config.
    var databases = DatabasesConfig()
    // Configure a MySQL database
    
    
//    guard let hostname = Environment.get("hostname"),
//        let username = Environment.get("username"),
//        let password = Environment.get("password"),
//        let database = Environment.get("database") else {
//            fatalError("You must set your environment variables")
//    }
    
//    let config = MySQLDatabaseConfig(hostname: hostname,
//                                     port: 3306,
//                                     username: username,
//                                     password: password,
//                                     database: database)
    
    let config = MySQLDatabaseConfig(hostname: "127.0.0.1",
                                     port: 3306,
                                     username: "vapor",
                                     password: "1234",
                                     database: "CapoServer",
                                     transport: .unverifiedTLS)

    
    databases.add(database: MySQLDatabase(config: config), as: .mysql)

    databases.enableLogging(on: .mysql)
    services.register(databases)
    
    
    
    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .mysql)
    migrations.add(model: UserToken.self, database: .mysql)
    migrations.add(model: Event.self, database: .mysql)
        migrations.add(model: Group.self, database: .mysql)
    migrations.add(model: EventUserPivot.self, database: .mysql)
        migrations.add(model: GroupUserPivot.self, database: .mysql)
    //    migrations.add(migration: AddEventType.self, database: .mysql)
    //    migrations.add(migration: EventTypeCleanup.self, database: .mysql)
    services.register(migrations)

    var commands = CommandConfig.default()
    commands.useFluentCommands()
    services.register(commands)
//    vapor build && vapor run revert --all
}
