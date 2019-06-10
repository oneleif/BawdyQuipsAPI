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
        case .SelectCard:
            return selectCard(req)
        case .GoToVoting:
            return goToVoting(req)
        case .VoteForAnswer:
            return voteForAnswer(req)
        case .GoToScoring:
            return goToScoring(req)
        }
    }
    
    func goToGame(_ req: Request) -> Future<GameUpdate> {
        guard let roomID = update.room else{
            return Future.map(on: req) { return self.update }
        }
        
        return Room.find(roomID, on: req).flatMap { (room) -> (Future<GameUpdate>) in
            // Check if the admin is sending this request
            guard let room = room,
                self.update.user == room.admin else {
                    return Future.map(on: req) { return self.update }
            }
            
            // If the room's card desk is empty, end the game
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
                // set random judge of this round
                room.judge = room.users.random
                // set card in hand
                var hands: [User.ID: [Card]] = [:]
                for user in room.users {
                    // MARK: we need to check if the user already has 7 cards
                    // cards should be stored in the User, not in the update
                    let hand = room.cardDeck.getRandomCards(numberOfCards: 7, isPrompt: false)
                    hands[user] = hand
                }
                newUpdate.hands = hands
                
                // set the current prompt
                // MARK: does this actually update the database?
                let prompt : Card? = room.cardDeck.getRandomCards(numberOfCards: 1, isPrompt: true)[0]
                room.currentPrompt = prompt
                return Future.map(on: req) { return newUpdate }
            }
        }
    }
    
    func selectCard(_ req: Request) -> Future<GameUpdate> {
        //remove update.playerSelectedCards from update.user.handOfCards
        //add to update.cardsToVoteOn
        guard let userID = update.user else{
            return Future.map(on: req) { return self.update }
        }
        
        return User.find(userID, on: req).flatMap { (user) -> (Future<GameUpdate>) in
            guard let user = user else {
                    return Future.map(on: req) { return self.update }
            }
            
            var newUpdate = self.update
            
            guard let playerSelectedCards = newUpdate.playerSelectedCards else{
                return Future.map(on: req) { return self.update }
            }
            
            user.handOfCards = user.handOfCards?.filter{ !playerSelectedCards.contains($0) }
            newUpdate.playerSelectedCards = []
            newUpdate.cardsToVoteOn?[user] = user.handOfCards
            
            return Future.map(on: req) { return newUpdate }
        }
    }

    func goToVoting(_ req: Request) -> Future<GameUpdate> {
        var newUpdate = update
        newUpdate.scene = GameUpdate.Scenes.Voting
        return Future.map(on: req) { return newUpdate }
    }
    
    func voteForAnswer(_ req: Request) -> Future<GameUpdate> {
        // Check that the update.user is coming from the update.room.judge
        guard let roomID = update.room
         else{
            return Future.map(on: req) { return self.update }
        }
        
        return Room.find(roomID, on: req).flatMap { (room) -> (Future<GameUpdate>) in
            guard let room = room,
                self.update.user == room.judge else {
                    return Future.map(on: req) { return self.update }
            }
            
            self.updateGoldUser(req)
            self.updateSilverUser(req)
            self.updateBronzeUser(req)
            
            return Future.map(on: req) { return self.update }
        }
    }
    
    func updateGoldUser(_ req: Request) -> Future<GameUpdate> {
        // get the userID for the gold award
        guard let goldUserID = self.update.goldAward else{
            return Future.map(on: req) { return self.update }
        }
        
        // update the score of the gold awarded user
        return User.find(goldUserID, on: req).flatMap { (goldUser) -> (Future<GameUpdate>) in
            guard let goldUser = goldUser else{
                return Future.map(on: req) { return self.update }
            }
            
            goldUser.currentScore.gold += 1
            goldUser.update(on: req)
            
            return Future.map(on: req) { return self.update }
        }
    }
    
    func updateSilverUser(_ req: Request) -> Future<GameUpdate> {
        // get the userID for the gold award
        guard let silverUserID = self.update.silverAward else{
            return Future.map(on: req) { return self.update }
        }
        
        // update the score of the gold awarded user
        return User.find(silverUserID, on: req).flatMap { (silverUser) -> (Future<GameUpdate>) in
            guard let silverUser = silverUser else{
                return Future.map(on: req) { return self.update }
            }
            
            silverUser.currentScore.gold += 1
            silverUser.update(on: req)
            
            return Future.map(on: req) { return self.update }
        }
    }
    
    func updateBronzeUser(_ req: Request) -> Future<GameUpdate> {
        // get the userID for the gold award
        guard let bronzeUserID = self.update.bronzeAward else{
            return Future.map(on: req) { return self.update }
        }
        
        // update the score of the gold awarded user
        return User.find(bronzeUserID, on: req).flatMap { (bronzeUser) -> (Future<GameUpdate>) in
            guard let bronzeUser = bronzeUser else{
                return Future.map(on: req) { return self.update }
            }
            
            bronzeUser.currentScore.gold += 1
            bronzeUser.update(on: req)
            
            return Future.map(on: req) { return self.update }
        }
    }

    func goToScoring(_ req: Request) -> Future<GameUpdate> {
        var newUpdate = update
        newUpdate.scene = GameUpdate.Scenes.Scoreboard
        return Future.map(on: req) { return newUpdate }
    }
}
