import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let sessionManager = TrackingSessionManager.tracking
    
    let usersController = UserController()
    try router.register(collection: usersController)
    
    // MARK: Status Checks
    router.get("status") { _ in "ok \(Date())" }
    
    router.get("word-test") { request in
        return wordKey(with: request)
    }
    
    // MARK: Poster Routes
    router.post("create", use: sessionManager.createTrackingSession)
    
    router.post("close", TrackingSession.parameter) { req -> HTTPStatus in
        let session = try req.parameters.next(TrackingSession.self)
        sessionManager.close(session)
        return .ok
    }
    
    router.post("update", TrackingSession.parameter) { req -> Future<HTTPStatus> in
        let session = try req.parameters.next(TrackingSession.self)
        return try Location.decode(from: req).map(to: HTTPStatus.self) { location in
            sessionManager.update(for: session)
            return .ok
        }
    }
}
