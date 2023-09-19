//
//  HandAndFootGame.swift
//  HandAndFoot
//
//  Created by Helder Melendez on 7/26/23.
//

import Foundation

class HandAndFootGame : ObservableObject {
    @Published private var model = HandAndFoot()
    
    func initializeGame() throws {
        try model.initializeGame()
    }
    
    var players: [Player] {
        return model.players
    }
    
    func getTeams() -> [Team] {
        return model.getTeams()
    }

    func getHumanPlayer() -> Player {
        return model.getHumanPlayer()
    }

    func getCurrentPlayer() -> Player {
        return model.currentPlayer
    }
    
    func getCurrentRound() -> Round {
        return model.getCurrentRound()
    }
    
    func select(card: Card, player: Player) {
         model.select(card: card, player: player)
    }
}
