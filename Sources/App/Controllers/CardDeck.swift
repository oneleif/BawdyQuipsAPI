//
//  CardDeck.swift
//  App
//
//  Created by Sabien Ambrose on 6/6/19.
//

import Foundation

class CardDeck: Codable, Hashable {
    static func == (lhs: CardDeck, rhs: CardDeck) -> Bool {
        return lhs.answerCards == rhs.answerCards &&
        lhs.promptCards == rhs.promptCards
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(answerCards)
        hasher.combine(promptCards)
    }
    
    var answerCards: [Card] = []
    var promptCards: [Card] = []
    
    init(){
        
    }
    
    init(answers: [Card], prompts: [Card]){
        answerCards = answers
        promptCards = prompts
    }
    
    func getRandomCards(numberOfCards: Int, isPrompt: Bool) -> [Card] {
        var toReturn : [Card] = []
        for _ in 0..<numberOfCards {
            if isPrompt{
                guard let randomCard = promptCards.random else { continue }
                toReturn.append(randomCard)
                promptCards = promptCards.filter{$0 != randomCard}
            }else{
                guard let randomCard = answerCards.random else { continue }
                toReturn.append(randomCard)
                answerCards = answerCards.filter{$0 != randomCard}
            }
        }
        
        return toReturn
    }
}
