import Vapor

struct RoomUpdate: Content, Codable {
    enum AwardType: Int, Codable {
        case Gold
        case Silver
        case Bronze
    }
    var update: GameUpdate
    
    func getUpdate(_ req: Request) throws -> Future<GameUpdate> {
         return try GameUpdate.decode(from: req).flatMap { (update) -> Future<GameUpdate> in
            switch update.updateType {
                //        case .CreateLobby:
                //            return createLobby(req)
                //        case .GoToGame:
                //            return try goToGame(req)
                //        case .SelectCard:
                //            return selectCard(req)
                //        case .GoToVoting:
                //            return goToVoting(req)
                //        case .VoteForAnswer:
                //            return voteForAnswer(req)
                //        case .GoToScoring:
            //            return goToScoring(req)
            default:
                return Future.map(on: req) { return self.update }
            }
        }
    }
    
//    func createLobby(_ req: Request) -> Future<GameUpdate> {
//        
//    }
    
//    func goToGame(_ req: Request) throws -> Future<GameUpdate> {
//        return try GameUpdate.decode(from: req).flatMap { (update) -> Future<GameUpdate> in
//
//            guard let roomID = update.room else{
//                return Future.map(on: req) { return self.update }
//            }
//
//            return Room.find(roomID, on: req).flatMap { (room) -> (Future<GameUpdate>) in
//                // Check if the admin is sending this request
//                guard let room = room,
//                    self.update.user == room.admin else {
//                        return Future.map(on: req) { return self.update }
//                }
//
//                // If the room's card desk is empty, end the game
//                if room.cardDeck.promptCards.count == 0 ||
//                    room.cardDeck.answerCards.count == 0 {
//                    // MARK: end game somehow
//                    return Future.map(on: req) { return self.update }
//                } else {
//                    // clean room
//                    var newUpdate = self.update
//                    newUpdate.scene = GameUpdate.Scenes.Playing
//                    newUpdate.cardsToVoteOn = [:]
//                    newUpdate.playerSelectedCards = []
//                    // set random judge of this round
//                    room.judge = room.users.random
//                    // set card in hand
//                    var hands: [User.ID: [Card]] = [:]
//                    for user in room.users {
//                        // MARK: we need to check if the user already has 7 cards
//                        // cards should be stored in the User, not in the update
//                        let hand = room.cardDeck.getRandomCards(numberOfCards: 7, isPrompt: false)
//                        hands[user] = hand
//                    }
//                    newUpdate.hands = hands
//
//                    // set the current prompt
//                    // MARK: does this actually update the database?
//                    let prompt : Card? = room.cardDeck.getRandomCards(numberOfCards: 1, isPrompt: true)[0]
//                    room.currentPrompt = prompt
//                    return Future.map(on: req) { return newUpdate }
//                }
//            }
//        }
//    }
    
//    func selectCard(_ req: Request) -> Future<GameUpdate> {
//        //remove update.playerSelectedCards from update.user.handOfCards
//        //add to update.cardsToVoteOn
//        guard let userID = update.user else{
//            return Future.map(on: req) { return self.update }
//        }
//
//        return User.find(userID, on: req).flatMap { (user) -> (Future<GameUpdate>) in
//            guard let user = user else {
//                    return Future.map(on: req) { return self.update }
//            }
//
//            var newUpdate = self.update
//
//            guard let playerSelectedCards = newUpdate.playerSelectedCards else{
//                return Future.map(on: req) { return self.update }
//            }
//
//            user.handOfCards = user.handOfCards?.filter{ !playerSelectedCards.contains($0) }
//            newUpdate.playerSelectedCards = []
//            newUpdate.cardsToVoteOn?[user] = user.handOfCards
//
//            return Future.map(on: req) { return newUpdate }
//        }
//    }

    func goToVoting(_ req: Request) -> Future<GameUpdate> {
        var newUpdate = update
        newUpdate.scene = GameUpdate.Scenes.Voting
        return Future.map(on: req) { return newUpdate }
    }
    
//    func voteForAnswer(_ req: Request) -> Future<GameUpdate> {
//        // Check that the update.user is coming from the update.room.judge
//        guard let roomID = update.room
//         else{
//            return Future.map(on: req) { return self.update }
//        }
//        
//        return Room.find(roomID, on: req).flatMap { (room) -> (Future<GameUpdate>) in
//            guard let room = room,
//                let gold = self.update.goldAward,
//                let silver = self.update.silverAward,
//                let bronze = self.update.bronzeAward,
//                self.update.user == room.judge else {
//                    return Future.map(on: req) { return self.update }
//            }
//            
//            
//            return flatMap(self.updateUser(req, .Gold, gold),
//                           self.updateUser(req, .Silver, silver),
//                           self.updateUser(req, .Bronze, bronze)) { (gold, silver, bronze) -> Future<GameUpdate> in
//                            //update()
//                Future.map(on: req) { return self.update }
//            }
//        }
//    }
    
    func updateUser(_ req: Request, _ award: AwardType, _ user: User.ID) -> Future<User.ID?> {
        // update the score of the gold awarded user
        return User.find(user, on: req)
            .flatMap { (user) -> (Future<User.ID?>) in
            guard let user = user else{
                return Future.map(on: req) { return nil }
            }
            switch award {
            case .Gold:
                user.currentScore.gold += 1
            case .Silver:
                user.currentScore.silver += 1
            case .Bronze:
                user.currentScore.bronze += 1
            }
                
            user.update(on: req)
            
            return Future.map(on: req) { return user.id }
        }
    }

    func goToScoring(_ req: Request) -> Future<GameUpdate> {
        var newUpdate = update
        newUpdate.scene = GameUpdate.Scenes.Scoreboard
        return Future.map(on: req) { return newUpdate }
    }
}
