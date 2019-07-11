import Vapor
import WebSocket

// MARK: For the purposes of this example, we're using a simple global collection.
// in production scenarios, this will not be scalable beyond a single server
// make sure to configure appropriately with a database like Redis to properly
// scale
final class RoomSessionManager {
    private(set) var connections: LockedDictionary<String, Connections> = [:]
    
    public static var rooms: RoomSessionManager = {
        return RoomSessionManager()
    }()
    
    // MARK: Observer Interactions
    func add(listener: WebSocket, to session: String) {
        //verify session exists
        guard var listeners = connections[session]?.sessions else { return }
        //add observer's websocket to our listeners
        listeners.append(listener)
        connections[session]?.sessions = listeners
        
        //remove client room listeners on close
        listener.onClose.always { [weak self, weak listener] in
            guard let listener = listener else { return }
            self?.remove(listener: listener, from: session)
        }
    }
    
    func remove(listener: WebSocket, from session: String) {
        guard var listeners = connections[session]?.sessions else { return }
        listeners = listeners.filter { $0 !== listener }
        connections[session]?.sessions = listeners
    }

    // MARK: Poster Interactions
    func createRoomSession(for request: Request) -> Future<String> {
        //Create session ID
        return wordKey(with: request)
            .flatMap(to: String.self) { [unowned self] key -> Future<String> in                //Ensure the ID is unique, if not generate a new one
                guard self.connections[key] == nil else {
                    return self.createRoomSession(for: request)
                }
                let connection: Connections = Connections(room: RoomSession(update: nil, room: Room(), id: key), sessions: [WebSocket](), id: key)
                //Record the new RoomSession and give it no observers
                self.connections[key] = connection
                
                
                return Future.map(on: request) { key }
        }
    }

    //when a Poster sends an update, send to each registered observer
    func update(_ object: RoomSession, for session: String) {
        guard let listeners = connections[session]?.sessions else { return }
        listeners.forEach { ws in ws.send(object) }
    }

    //close the Observer's webSocket
    func close(_ session: String) {
        guard let listeners = connections[session]?.sessions else { return }
        listeners.forEach { ws in
            ws.close()
        }
        connections[session] = nil
    }
}


