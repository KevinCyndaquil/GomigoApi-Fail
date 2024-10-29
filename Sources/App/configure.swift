import NIOSSL
import Fluent
import FluentMongoDriver
import Leaf
import Vapor
import JWT

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    try app.databases.use(.mongo(
        connectionString: Environment.get("DATABASE_URL") ?? "mongodb://localhost:27017/test"
    ), as: .mongo)

    app.views.use(.leaf)

    // register routes
    try routes(app)
}
