import FluentSQLite
import Vapor
import VaporGraphQL
import Authentication


/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    try services.register(FluentSQLiteProvider())
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
    
    
    // Configure a SQLite database
    let sqlite = try SQLiteDatabase(storage: .file(path: "dat.sqlite"))//.file(path: "dat.sqlite")
    // Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    databases.enableLogging(on: .sqlite)
    databases.add(database: sqlite, as: .sqlite)
    services.register(databases)
    
    
    
    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .sqlite)
    migrations.add(model: UserToken.self, database: .sqlite)
    migrations.add(model: Event.self, database: .sqlite)
    //    migrations.add(model: Group.self, database: .sqlite)
    migrations.add(model: EventUserPivot.self, database: .sqlite)
    //    migrations.add(model: GroupUserPivot.self, database: .sqlite)
    //    migrations.add(migration: AddEventType.self, database: .sqlite)
    //    migrations.add(migration: EventTypeCleanup.self, database: .sqlite)
    services.register(migrations)

}
