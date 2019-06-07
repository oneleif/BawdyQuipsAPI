import Vapor

struct RoomUpdate: Content, Codable {
    enum UpdateType: Int, Codable {
        case VoteForCard
        case SelectCard
        case VoteForAnswer
        case GoToGame
        case GoToVoting
        case GoToScoring
    }
    
    let updateType: UpdateType
    
    //TODO change type to GameUpdate, that holds info about each type of update
    let update: GameUpdate
    
    func getUpdate() -> String {
        switch updateType {
        case .VoteForCard:
            return getGoToGameUpdate()
        case .SelectCard:
            return getSelectCard()
        case .VoteForAnswer:
            return getGoToGameUpdate()
        case .GoToGame:
            return getGoToGameUpdate()
        case .GoToVoting:
            return getGoToGameUpdate()
        case .GoToScoring:
            return getGoToGameUpdate()
        }
        
    }
    
    
    //TODO create event response model
    func getGoToGameUpdate() -> String {
        //tell them to call getRandomCards()
        return ""
    }
    
    func getSelectCard() -> String {
        //add a card to face down stack and remove from my hand
        return ""
    }
    
    func getVoteForAnswer() -> String {
        //sends the voted for answer
        return ""
    }
    
    func getGoToVoting() -> String {
        //tell them to call getRandomCards()
        return ""
    }
}
