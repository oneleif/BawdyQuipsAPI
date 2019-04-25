import io.javalin.Context;
import io.javalin.apibuilder.CrudHandler;
import org.jetbrains.annotations.NotNull;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.HashMap;
import java.util.Map;

public class UserController implements CrudHandler {
    private static final Logger LOGGER = LoggerFactory.getLogger(UserController.class);

    private Map<String, User> users = new HashMap<>();

    public void create(@NotNull Context context) {
        User user = context.bodyAsClass(User.class);
        LOGGER.info("Create a new user {}", user);
        this.users.put(user.getId(), user);
    }

    public void delete(@NotNull Context context, @NotNull String resourceId) {
        LOGGER.info("Delete the user {}", resourceId);
        this.users.remove(resourceId);
    }

    public void getAll(@NotNull Context context) {
        LOGGER.info("Get all users");
        context.json(users.values());
    }

    public void getOne(@NotNull Context context, @NotNull String resourceId) {
        LOGGER.info("Get the user {}", resourceId);
        User users = this.users.get(resourceId);
        if (users != null) {
            context.json(users);
        }
    }

    public void update(@NotNull Context context, @NotNull String resourceId) {
        LOGGER.info("Update the user {}", resourceId);
        User user = context.bodyAsClass(User.class);
        this.users.put(resourceId, user);
    }
}
