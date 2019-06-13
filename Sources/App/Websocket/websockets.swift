import Vapor
import WebSocket

public func sockets(_ websockets: NIOWebSocketServer) {
    let sessionManager = RoomSessionManager.rooms
    
    // Create a WebSocket handler at /listen
    websockets.get("join", RoomSession.parameter) { ws, req in
        //get session ID from the URL
        let session = try req.parameters.next(RoomSession.self)
        //Ensure the session is valid, if not close it
        guard sessionManager.sessions[session] != nil else {
            ws.close()
            return
        }
        //add WebSocket to the session as an Observer
        sessionManager.add(listener: ws, to: session)
    }
}

extension WebSocket {
    func send(_ object: GameUpdate) {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(object) else { return }
        send(String(data: data, encoding: .utf8)!)
    }
}
