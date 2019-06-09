import Vapor

struct RoomUpdate: Content, Codable {
    enum UpdateType: Int, Codable {
        case GoToGame
        case SelectCard
        case GoToVoting
        case VoteForAnswer
        case GoToScoring
    }
    
    let updateType: UpdateType
    
    var update: GameUpdate
    
    func getUpdate(_ req: Request) -> Future<GameUpdate> {
        switch updateType {
        case .GoToGame:
            return goToGame(req)
        default :
            return Future.map(on: req) { return self.update }
            
            //        case .SelectCard:
            //            return selectCard(req)
            //        case .GoToVoting:
            //            return goToVoting(req)
            //        case .VoteForAnswer:
            //            return voteForAnswer(req)
            //        case .GoToScoring:
            //            return goToScoring(req)
        }
    }
    
    func goToGame(_ req: Request) -> Future<GameUpdate> {
        guard let roomID = update.room else{
            return Future.map(on: req) { return self.update }
        }
        
        return Room.find(roomID, on: req).flatMap { (room) -> (Future<GameUpdate>) in
            guard let room = room,
                self.update.user == room.admin else {
                    return Future.map(on: req) { return self.update }
            }
            
            if room.cardDeck.promptCards.count == 0 ||
                room.cardDeck.answerCards.count == 0 {
                // MARK: end game somehow
                return Future.map(on: req) { return self.update }
            } else {
                // clean room
                var newUpdate = self.update
                newUpdate.scene = GameUpdate.Scenes.Playing
                newUpdate.cardsToVoteOn = [:]
                newUpdate.playerSelectedCards = []
                // set admin
                room.admin = room.users.random
                // set card in hand
                var cards = CardDeck().promptCards
                var hands: [User.ID: [Card]] = [:]
                for user in room.users {
                    let hand = room.cardDeck.getRandomCards(numberOfCards: 7, isPrompt: false)
                    hands[user] = hand
                }
                
                newUpdate.hands = hands
                return Future.map(on: req) { return newUpdate }
            }
        }
        
        // Check if the admin is sending this request
        
        // If the room's card desk is empty, end the game
        
        
        // Query to get the correct room
        // Select a random user to be the judge
        
        // For each user in the room
        // If they don't have 7 cards, get random cards until 7
        // Use the following to get random cards:
        // CardDeck.cardDeck.getRandomCards(numberOfCards: 7, isPrompt: false)
        
        // Choose a prompt card and set it:
        // update.room?.currentPrompt = CardDeck.cardDeck.getRandomCards(numberOfCards: 1, isPrompt: true)[0]
        
        //            return newUpdate
    }
    
    
    
    //    func selectCard(_ req: Request) -> Future<GameUpdate> {
    //        //remove update.playerSelectedCards from update.user.handOfCards
    //        //add to update.cardsToVoteOn
    //
    //        return update
    //    }
    //
    //    func goToVoting(_ req: Request) -> Future<GameUpdate> {
    //        var newUpdate = update
    //        newUpdate.scene = GameUpdate.Scenes.Voting
    //        return newUpdate
    //    }
    //
    //    func voteForAnswer(_ req: Request) -> Future<GameUpdate> {
    //        // Check that the update.user is coming from the update.room.judge, lookup by ID somehow
    //
    //        //add to the player's score who played the card
    //        return update
    //    }
    //
    //    func goToScoring(_ req: Request) -> Future<GameUpdate> {
    //        var newUpdate = update
    //        newUpdate.scene = GameUpdate.Scenes.Scoreboard
    //        return newUpdate
    //    }
}
