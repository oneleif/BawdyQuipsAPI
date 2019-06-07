import Vapor

struct RoomUpdate: Content {
    enum UpdateType: Int, Codable {
        case GoToGame
        case SelectCard
        case GoToVoting
        case VoteForAnswer
        case GoToScoring
    }
    
    let updateType: UpdateType
    
    var update: GameUpdate
    
    func getUpdate() -> GameUpdate {
        switch updateType {
        case .GoToGame:
            return goToGame()
        case .SelectCard:
            return selectCard()
        case .GoToVoting:
            return goToVoting()
        case .VoteForAnswer:
            return voteForAnswer()
        case .GoToScoring:
            return goToScoring()
        }
    }
    
    func goToGame() -> GameUpdate {
        // Check if the admin is sending this request
        
            // If the room's card desk is empty, end the game
            var newUpdate = update
            newUpdate.scene = GameUpdate.Scenes.Playing
            newUpdate.cardsToVoteOn = [:]
            newUpdate.playerSelectedCards = []
        
            // Query to get the correct room
            // Select a random user to be the judge
        
            // For each user in the room
            // If they don't have 7 cards, get random cards until 7
                // Use the following to get random cards:
                // CardDeck.cardDeck.getRandomCards(numberOfCards: 7, isPrompt: false)
            
            // Choose a prompt card and set it:
            // update.room?.currentPrompt = CardDeck.cardDeck.getRandomCards(numberOfCards: 1, isPrompt: true)[0]
            
            return newUpdate
    }
    
    func selectCard() -> GameUpdate {
        //remove update.playerSelectedCards from update.user.handOfCards
        //add to update.cardsToVoteOn
        
        return update
    }
    
    func goToVoting() -> GameUpdate {
        var newUpdate = update
        newUpdate.scene = GameUpdate.Scenes.Voting
        return newUpdate
    }
    
    func voteForAnswer() -> GameUpdate {
        // Check that the update.user is coming from the update.room.judge, lookup by ID somehow
        
        //add to the player's score who played the card
        return update
    }
    
    func goToScoring() -> GameUpdate {
        var newUpdate = update
        newUpdate.scene = GameUpdate.Scenes.Scoreboard
        return newUpdate
    }
}
