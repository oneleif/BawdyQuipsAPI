import io.javalin.Context;
import io.javalin.apibuilder.CrudHandler;
import org.jetbrains.annotations.NotNull;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.HashMap;
import java.util.Map;

public class CardController implements CrudHandler {
    private static final Logger LOGGER = LoggerFactory.getLogger(CardController.class);

    private Map<String, Card> cards = new HashMap<>();

    public void create(@NotNull Context context) {
        Card card = context.bodyAsClass(Card.class);
        LOGGER.info("Create a new user {}", card);
        this.cards.put(card.getId(), card);
    }

    public void delete(@NotNull Context context, @NotNull String resourceId) {
        LOGGER.info("Delete the card {}", resourceId);
        this.cards.remove(resourceId);
    }

    public void getAll(@NotNull Context context) {
        LOGGER.info("Get all card");
        context.json(cards.values());
    }

    public void getOne(@NotNull Context context, @NotNull String resourceId) {
        LOGGER.info("Get the card {}", resourceId);
        Card card = this.cards.get(resourceId);
        if (card != null) {
            context.json(card);
        }
    }

    public void update(@NotNull Context context, @NotNull String resourceId) {
        LOGGER.info("Update the card {}", resourceId);
        Card card = context.bodyAsClass(Card.class);
        this.cards.put(resourceId, card);
    }
}
