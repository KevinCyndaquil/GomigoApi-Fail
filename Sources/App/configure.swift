import NIOSSL
import Fluent
import FluentMongoDriver
import Leaf
import Vapor
import JWT

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    try app.databases.use(.mongo(
        connectionString: Environment.get("DATABASE_URL") ?? "mongodb://localhost:27017/test"
    ), as: .mongo)
    
    app.jwt.signers.use(.hs256(key: "4908ff62d22da6f062d92eb56c46b766df39dbf47a914fd122b466b75b890b7f5765344cc013dd9d2d5b9c1f22546f1cc58863cf8e31406592e2b561beb41fc71506109479bcad8ac3f4af6f5a05df50b2567e83ab26da31a9b4b2affdfe45d5b3ccc2ba393de43fb796332dd97e5acbfa27782b53f8c328dced314378e4d99de3ef1f6f23a4bdafc9773d27813d7c66d2e3b004a4095db033d4fda891efdb1f08cd3d4be84eef0fbe01193138e7e0151f80ecbd1f682a1c2bd1d0da769b4c648163416ddd2e0ce223422725e479d8b33063cec1224ea60b14a48466c169bb22c0df3a17554fcce440e224912d1f009a61a939a70841fa52570fe3e23f8bcea4"))
    
    app.migrations.add(CreateTodo())

    app.views.use(.leaf)


    // register routes
    try routes(app)
}
