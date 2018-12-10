import FluentMySQL
import Vapor
import VaporGraphQL
import Authentication


/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
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
//    let config = MySQLDatabaseConfig.root(database: "CapoServer")
    let config = MySQLDatabaseConfig(hostname: DatabaseConfig.hostname,
                                     port: 3306,
                                     username: DatabaseConfig.username,
                                     password: DatabaseConfig.password,
                                     database: DatabaseConfig.database
//                                    ,transport: .unverifiedTLS
    )
    
    databases.add(database: MySQLDatabase(config: config), as: .mysql)
//    let sqlite = try SQLiteDatabase(storage: .file(path: "dat.sqlite"))//.file(path: "dat.sqlite")

    databases.enableLogging(on: .mysql)
//    databases.add(database: sqlite, as: .sqlite)
    services.register(databases)
    
    
    
    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .mysql)
    migrations.add(model: UserToken.self, database: .mysql)
    migrations.add(model: Event.self, database: .mysql)
    //    migrations.add(model: Group.self, database: .mysql)
    migrations.add(model: EventUserPivot.self, database: .mysql)
    //    migrations.add(model: GroupUserPivot.self, database: .mysql)
    //    migrations.add(migration: AddEventType.self, database: .mysql)
    //    migrations.add(migration: EventTypeCleanup.self, database: .mysql)
    services.register(migrations)

}
