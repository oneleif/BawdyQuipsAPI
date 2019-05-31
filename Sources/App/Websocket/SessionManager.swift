import Vapor
import WebSocket

// MARK: For the purposes of this example, we're using a simple global collection.
// in production scenarios, this will not be scalable beyond a single server
// make sure to configure appropriately with a database like Redis to properly
// scale
final class RoomSessionManager {
    private(set) var sessions: LockedDictionary<RoomSession, [WebSocket]> = [:]
    
    public static var rooms: RoomSessionManager = {
        return RoomSessionManager()
    }()
    
    // MARK: Observer Interactions
    func add(listener: WebSocket, to session: RoomSession) {
        //verify session exists
        guard var listeners = sessions[session] else { return }
        
        //add observer's websocket to our listeners
        listeners.append(listener)
        sessions[session] = listeners
        
        //remove client room listeners on close
        listener.onClose.always { [weak self, weak listener] in
            guard let listener = listener else { return }
            self?.remove(listener: listener, from: session)
        }
    }
    
    func remove(listener: WebSocket, from session: RoomSession) {
        guard var listeners = sessions[session] else { return }
        listeners = listeners.filter { $0 !== listener }
        sessions[session] = listeners
    }

    // MARK: Poster Interactions
    func createRoomSession(for request: Request) -> Future<RoomSession> {
        //Create session ID
        return wordKey(with: request)
            .flatMap(to: RoomSession.self) { [unowned self] key -> Future<RoomSession> in
                //Create RoomSession for this session with ID
                let session = RoomSession(id: key)
                //Ensure the ID is unique, if not generate a new one
                guard self.sessions[session] == nil else {
                    return self.createRoomSession(for: request)
                }
                
                //Record the new RoomSession and give it no observers
                self.sessions[session] = []
                return Future.map(on: request) { session }
        }
    }

    //when a Poster sends an update, send to each registered observer
    func update<T: Codable>(_ object: T, for session: RoomSession) {
        guard let listeners = sessions[session] else { return }
        listeners.forEach { ws in ws.send(object) }
    }

    //close the Observer's webSocket
    func close(_ session: RoomSession) {
        guard let listeners = sessions[session] else { return }
        listeners.forEach { ws in
            ws.close()
        }
        sessions[session] = nil
    }
}


