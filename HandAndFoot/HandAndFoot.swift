//
//  Game.swift
//  HandAndFoot
//
//  Created by Helder Melendez on 7/20/23.
//

import Foundation
import SwiftUI

// All rules and terminology are from either: https://playingcarddecks.com/blogs/how-to-play/hand-and-foot-game-rules
// or https://bicyclecards.com/how-to-play/hand-and-foot
// The HandAndFoot game model keeps track of the actual game play, stock, moves, etc.
// A HandAndFoot game has N Rounds as determined by Settings.rounds and tracked by currentRound
// Within each Round each Player takes a turn which involves drawing from the stock pile or the discard pile, taking some action
// like laying down if the Team has not laid down cards, putting down new Melds, or adding to existing Melds
// The player turn ends when they discard to the discard pile unless it is their foot going out as determined by Settings.allowNoDiscardGoingOut
struct HandAndFoot {
    // 0-based index of rounds, e.g. first round is 0, second round is 1, etc.
    var currentRound: Int = 0
    var currentDealerPlayerIndex: Int = 0
    var currentPlayerIndex: Int = 0
    // The gameplay moves clockwise and begins with the player clockwise to the dealer
    var currentDealer: Player = Player.defaultPlayer()
    var currentPlayer: Player = Player.defaultPlayer()
    // Card piles
    // The initial unshuffled deck of cards we start every round with
    var cardDeck: [Card] = [Card]()
    // At the beginning of their turn they must take a card from either
    // the stock or the discard pile. The card stock is 2-D since some prefer
    // to have multiple stock piles
    var cardStockPile: [[Card]] = [[Card]]()
    // To take a card from the discard pile, the top card must either begin a meld
    // or build upon one already made but varies by Settings:
    // see Settings.allowDiscardPileOnExistingMeld
    var cardDiscardPile: [Card] = [Card]()
    var players: [Player] = [Player]()
    var teams:[Team] = [Team]()
    
    func getHumanPlayer() -> Player {
        for player in players {
            if player.isHuman {
                return player
            }
        }
        return Player.defaultPlayer()
    }
    
    func getTeams() -> [Team] {
        return teams
    }
    
    func getCurrentRound() -> Round {
        return Settings.currentSettings().rounds[self.currentRound]
    }

    mutating func select(card: Card, player: Player) {
        let whichHand = player.hand.count > 0 ? player.hand : player.foot
        if let cardIndex = whichHand.firstIndex(where: { $0.id == card.id}) {
            if let playerIndex = players.firstIndex(where: { $0.id == player.id}) {
                if player.hand.count > 0 {
                    players[playerIndex].hand[cardIndex].selected.toggle()
                } else {
                    players[playerIndex].foot[cardIndex].selected.toggle()
                }
            }
        }
    }

    mutating func initializeGame() throws {
        // As per https://playingcarddecks.com/blogs/how-to-play/hand-and-foot-game-rules
        // [Hand and Foot] is played with 2-6 players (even numbered total players or 2, 4, or 6)
        // Make sure total player count is valid: either 2, 4, or 6 players
        let totalPlayers = Settings.currentSettings().numberOfPlayersHuman + Settings.currentSettings().numberOfPlayersCPU
        if !([2, 4, 6].contains(totalPlayers)) {
            throw GamePlayError.invalidNumberOfPlayersExpected246(youGaveMe: totalPlayers)
            //return "Invalid # of Players, must be 2, 4, or 6, but you have: " + String(totalPlayers)
        } else {
            // Initialize players
            teams = Player.setDefaultPlayers(&self.players)
            // Set dealer button
            self.currentDealer = self.players[self.currentDealerPlayerIndex]
            self.currentPlayerIndex = self.currentDealerPlayerIndex
            self.advanceNextPlayer()
            initializeRound()

        }
    }
    
    mutating func advanceNextPlayer() {
        self.currentPlayerIndex += 1
        if self.currentPlayerIndex >= self.players.count {
            self.currentPlayerIndex = 0
        }
        self.currentPlayer = self.players[self.currentPlayerIndex]
        self.currentPlayer.playerHasDrawnThisTurn = false
        self.currentPlayer.playerHasDiscardedThisTurn = false
    }
    
    mutating func initializeCardDecks() {
        self.cardDeck.removeAll()
        for _ in 1...Settings.currentSettings().numberOfDecks {
            // 13 cards in a suit * 4 suits = 52 cards
            for rank in Rank.allCases {
                for suit in Suit.allCases {
                    let card = Card.getCard(suit: suit, rank: rank)
                    self.cardDeck.append(card)
                }
            }
            // Add two jokers and that makes 54 cards in a deck:
            // the suits on a Joker card don't really matter
            // but we add a black (Club) and a red (Diamond) joker
            self.cardDeck.append(Card.getCard(suit: Suit.Club, rank: Rank.RankJoker))
            self.cardDeck.append(Card.getCard(suit: Suit.Diamond, rank: Rank.RankJoker))
        }
    }
    
    mutating func initializeStockPiles() {
        self.cardStockPile.removeAll()
        // Create the stock pile arrays, initially empty
        for _ in 1...Settings.currentSettings().numberOfStockPiles {
            self.cardStockPile.append([Card]())
        }
        // Now for each card in the cardDeck, select one at random and move it to each stock pile, round robin
        // Shout out to user Adolfo for this method of "getting random cards" at
        // https://stackoverflow.com/a/37992376/2788414
        var nextStockPile: Int = 0
        while (self.cardDeck.count > 0) {
            let randomPosition: Int = Int(arc4random_uniform(UInt32(self.cardDeck.count)))
            let card: Card = cardDeck.remove(at: randomPosition)
            self.cardStockPile[nextStockPile].append(card)
            // Go to the next stock pile
            nextStockPile += 1
            // If the next stock pile exceeds the total stock pile count then reset to the first one at 0
            if (nextStockPile >= self.cardStockPile.count) {
                nextStockPile = 0
            }
        }
    }
    
    mutating func initializePlayerHandAndFoot() {
        // Start with currentDealerPlayerIndex + 1, if that equals or exceeds total player count then start back at 0
        var nextDeal: Int = self.currentDealerPlayerIndex + 1
        if (nextDeal >= self.players.count) {
            nextDeal = 0
        }
        var nextStockPile: Int = 0
        let currentCardCountToDeal = getCurrentRound().numberOfCardsPerHandFoot
        while (self.cardStockPile[nextStockPile].count > 1) {
            if self.players[nextDeal].hand.count == currentCardCountToDeal {
                break
            }
            // Get next Card for hand
            self.players[nextDeal].hand.append(self.cardStockPile[nextStockPile].removeFirst())
            // Get next Card for foot
            self.players[nextDeal].foot.append(self.cardStockPile[nextStockPile].removeFirst())
            // Go to the next stock pile
            nextStockPile += 1
            // If the next stock pile exceeds the total stock pile count then reset to the first one at 0
            if (nextStockPile >= self.cardStockPile.count) {
                nextStockPile = 0
            }
            // Go to the next Player
            nextDeal += 1
            if (nextDeal >= self.players.count) {
                nextDeal = 0
            }
        }
        // Sort cards by value
        for player in self.players {
            player.hand.sort(by: {$1.value > $0.value})
            player.foot.sort(by: {$1.value > $0.value})
        }
    }
    
    mutating func initializeDiscardPile() {
        self.cardDiscardPile.removeAll()
        var nextStockPile: Int = 0
        for _ in 1...Settings.currentSettings().numberOfMinCardsPickedFromDiscard {
            self.cardDiscardPile.append(self.cardStockPile[nextStockPile].removeFirst())
            // Go to the next stock pile
            nextStockPile += 1
            // If the next stock pile exceeds the total stock pile count then reset to the first one at 0
            if (nextStockPile >= self.cardStockPile.count) {
                nextStockPile = 0
            }
        }
    }
    
    mutating func initializeRound() {
        self.currentRound += 1
        initializeCardDecks()
        initializeStockPiles()
        initializePlayerHandAndFoot()
        initializeDiscardPile()
    }
    
    // currentPlayer chooses to draw N cards from the discard pile
    mutating func drawDiscardPile() throws {
        if cardDiscardPile.count == 0 {
            throw GamePlayError.discardPileIsEmpty
        }
        if self.currentPlayer.playerHasDrawnThisTurn {
            throw GamePlayError.playerHasAlreadyDrawnThisTurn
        }
        let topCard = cardDiscardPile.removeFirst()
        if topCard.isWildCard() {
            if !Settings.currentSettings().allowPickUpWildCardFromDiscard {
                cardDiscardPile.append(topCard)
                throw GamePlayError.discardPileCannotPickUpWildCard
            }
        } else if topCard.is3Card() {
            cardDiscardPile.append(topCard)
            throw GamePlayError.discardPileCannotPickUp3Card
        }
        // As per https://bicyclecards.com/how-to-play/hand-and-foot
        // "For 'picking up the pile'...the player must hold two cards of the same rank as the top card.
        // These three cards (the two he is holding and the top discard) must be immediately laid out,
        // possibly along with the other cards he is holding. Also keep in mind that, the player's team
        // must have melded till then, or he is melding while picking up the pile."
        if !currentPlayer.canMeldWithThisCard(card: topCard) {
            cardDiscardPile.append(topCard)
            throw GamePlayError.discardPilePlayerCannotMeldWithTopCard
        }
        // If the current player's Team has already laid down this round then there is no need to check for points to lay down,
        // otherwise, we have to check the discard pile gives this current player enough points to lay down for his Team
        var discardCards = [Card]()
        discardCards.append(topCard)
        while (discardCards.count < Settings.currentSettings().numberOfMinCardsPickedFromDiscard && cardDiscardPile.count > 0) {
            discardCards.append(cardDiscardPile.removeFirst())
        }
        if !currentPlayer.team.hasLaidDownCurrentRound {
            let targetPoints = Settings.currentSettings().rounds[self.currentRound].minPointsToLayDown
            let mypoints: Int = currentPlayer.getPointsInCurrentHand(targetPoints: targetPoints, addlCards: discardCards)
            if mypoints < targetPoints {
                // Put the discard cards back in reverse order to the begining of the discard pile, same order we picked them up in
                for aCard in discardCards.reversed() {
                    cardDiscardPile.insert(aCard, at: 0)
                }
                throw GamePlayError.discardPileCannotPickUpNotEnoughPointsToLayDown(needPoints: Settings.currentSettings().rounds[self.currentRound].minPointsToLayDown, hasPoints: mypoints)
            }
            for aCard in discardCards {
                self.currentPlayer.addCardToCurrentDeck(card: aCard)
            }
            try! currentPlayer.layDownCards(targetPoints: targetPoints)
        } else {
            try! currentPlayer.layDownMeld(topCard: topCard)
        }
        
        self.currentPlayer.playerHasDrawnThisTurn = true
     }
    
    // currentPlayer chooses to draw two cards from the stock pile
    mutating func drawStockPile(firstStockPile: Int, secondStockPile: Int) throws {
        if self.currentPlayer.playerHasDrawnThisTurn {
            throw GamePlayError.playerHasAlreadyDrawnThisTurn
        }
        if firstStockPile < 0 || firstStockPile >= cardStockPile.count {
            throw GamePlayError.invalidFirstStockPileNumber(youGaveMe: firstStockPile)
        }
        if cardStockPile[firstStockPile].count <= 0 {
            throw GamePlayError.emptyFirstStockPileNumber(youGaveMe: firstStockPile)
        }
        if secondStockPile < 0 || secondStockPile >= cardStockPile.count {
            throw GamePlayError.invalidSecondStockPileNumber(youGaveMe: secondStockPile)
        }
        let firstCard = cardStockPile[firstStockPile].removeFirst()
        if cardStockPile[secondStockPile].count <= 0 {
            // Put first card back, second card not valid
            cardStockPile[firstStockPile].append(firstCard)
            throw GamePlayError.emptySecondStockPileNumber(youGaveMe: secondStockPile)
        }
        let secondCard = cardStockPile[secondStockPile].removeFirst()
        self.currentPlayer.addCardToCurrentDeck(card: firstCard)
        self.currentPlayer.addCardToCurrentDeck(card: secondCard)
        
        self.currentPlayer.playerHasDrawnThisTurn = true
    }
    
    mutating func discardCard(card: Card) throws {
        if !self.currentPlayer.playerHasDrawnThisTurn {
            throw GamePlayError.playerHasToDrawBeforeDiscarding
        }
        // Get it out of the player's deck
        let cardToDiscard = self.currentPlayer.discardCard(card: card)
        if (cardToDiscard.value == 0) {
            throw GamePlayError.discardCardNotInPlayersDeck
        }
        // Add it to the discard pile
        self.cardDiscardPile.append(cardToDiscard)
        // If all goes well we advance the turn to the next player
        advanceNextPlayer()
        self.currentPlayer.playerHasDiscardedThisTurn = true
    }
}
