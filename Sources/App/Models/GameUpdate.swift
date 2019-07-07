//
//  GameUpdate.swift
//  App
//
//  Created by Sabien Ambrose on 6/4/19.
//

import Vapor

struct GameUpdate: Content, CustomStringConvertible {
    var description: String {
        return "\(user ?? 0)"
    }
    
    //TODO: create a subclass with the expected data for each enum value
    enum UpdateType: Int, Codable {
        //In lobby
        case PlayerJoined
        case ReadyUp
        case WaitingForGame
        case GoToGame
        //In game
        case SelectCard
        case WaitingForVoting
        case GoToVoting
        //In voting
        case VoteForAnswer
        case WaitingForScoring
        case GoToScoring
        //In scoreboard
        case WaitingForLobby
        case GoToLobby
    }
    
    var updateType: UpdateType?
    
    // The user sending the update
    var user: User.ID?
    
    //Playing Scene
    var hands: [User.ID: [Card.ID]]?
    var playerSelectedCards: [Card.ID]?
    var cardsToVoteOn: [User.ID: [Card.ID]]?
    
    //Voting Scene
    var goldAward: User.ID?
    var silverAward: User.ID?
    var bronzeAward: User.ID?
    
    //Scoreboard Scene
}

extension GameUpdate: Equatable, Hashable {
    
}

