import io.javalin.Javalin;
import io.javalin.websocket.WsSession;
import org.eclipse.jetty.websocket.api.Session;
import org.json.JSONObject;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import static io.javalin.apibuilder.ApiBuilder.crud;

public class ServerMain {
    private static Map<WsSession, String> userUsernameMap = new ConcurrentHashMap<>();
    private static int nextUserNumber = 1; // Assign to username for next connecting user

    public static void main(String[] args) {
        Javalin app = Javalin.create()
                .enableCorsForAllOrigins()
                .start(8080);

        app.routes(() -> crud("/users/:user-id", new UserController()));
    }
}
