//
//  HandAndFootTests.swift
//  HandAndFootTests
//
//  Created by Helder Melendez on 7/24/23.
//

import XCTest
@testable import HandAndFoot

final class HandAndFootTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testCard() throws {
        let card = Card.getCard(suit: Suit.Diamond, rank: Rank.RankAce)
        XCTAssertEqual(Rank.RankAce, card.rank)
        XCTAssertFalse(card.isWildCard())
        XCTAssertTrue(card.isRedCard())
        let cardMatching = Card.getCard(suit: Suit.Spade, rank: Rank.RankAce)
        XCTAssertTrue(card.isNaturalMatch(card: cardMatching))
        let cardNotMatching = Card.getCard(suit: Suit.Diamond, rank: Rank.RankKing)
        XCTAssertFalse(card.isNaturalMatch(card: cardNotMatching))
        XCTAssertEqual(Settings.currentSettings().scoreCardAces, card.getPointValue())
    }
    
    func testPlayerNoCards() throws {
        var players: [Player] = [Player]()
        Player.setDefaultPlayers(&players)
        XCTAssertTrue(players.count > 0)
        XCTAssertEqual(Settings.currentSettings().numberOfPlayersHuman + Settings.currentSettings().numberOfPlayersCPU, players.count)
        // No Cards delt so expect no points
        XCTAssertEqual(0, players[0].getPointsInCurrentHand(targetPoints: 50, addlCards: [Card]()))
        // Since no cards then no way to make any Meld
        let card = Card.getCard(suit: Suit.Heart, rank: Rank.RankJack)
        do {
            try players[0].layDownMeld(topCard: card)
            XCTFail("Should have failed with GamePlayError.notEnoughCardsForMatchingMeld")
        } catch GamePlayError.notEnoughCardsForMatchingMeld {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error")
        }
        // Since no cards then no way to lay down
        do {
            try players[0].layDownCards(targetPoints: 50)
            XCTFail("Should have failed with GamePlayError.cannotLayDownNotEnoughPoints")
        } catch GamePlayError.cannotLayDownNotEnoughPoints {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error")
        }
    }
    
    func testPlayerWithCards() throws {
        var players: [Player] = [Player]()
        Player.setDefaultPlayers(&players)
        XCTAssertTrue(players.count > 0)
        
        XCTAssertEqual(0, players[0].hand.count)
        XCTAssertEqual(0, players[0].team.melds.count)
        // Now to add some cards so that we can layDownMeld
        let card1 = Card.getCard(suit: Suit.Heart, rank: Rank.RankKing)
        players[0].hand.append(card1)
        XCTAssertEqual(1, players[0].hand.count)
        let card2 = Card.getCard(suit: Suit.Club, rank: Rank.RankKing)
        players[0].addCardToCurrentDeck(card: card2)
        XCTAssertEqual(2, players[0].hand.count)
        let topCard = Card.getCard(suit: Suit.Spade, rank: Rank.RankKing)
        do {
            try players[0].layDownMeld(topCard: topCard)
        } catch {
            XCTFail("Unexpected error")
        }
        XCTAssertEqual(0, players[0].hand.count)
        XCTAssertEqual(1, players[0].team.melds.count)
    }
    
    func testTeam() throws {
        let team: Team = Team.defaultTeam()
        XCTAssertFalse(team.hasLaidDownCurrentRound)
        XCTAssertEqual(0, team.score)
        XCTAssertEqual(0, team.melds.count)
        XCTAssertEqual(0, team.players.count)
    }
    
    func testMeld() throws {
        var players: [Player] = [Player]()
        Player.setDefaultPlayers(&players)
        XCTAssertTrue(players.count > 0)
        
        let meld:Meld = Meld(owner: players[0].team)
        
        XCTAssertEqual(0, meld.numberOfWildCards())
        XCTAssertEqual(0, meld.naturalValue())
        XCTAssertTrue(meld.isARedMeld()) // No cards therefore no wild cards either
        XCTAssertFalse(meld.isABook())
        XCTAssertTrue(meld.canAddCard(card: Card.getCard(suit: Suit.Diamond, rank: Rank.Rank4))) // No cards therefore no wild cards either
        
        // Now to add some cards
        meld.cards.append(Card.getCard(suit: Suit.Spade, rank: Rank.Rank5))
        meld.cards.append(Card.getCard(suit: Suit.Club, rank: Rank.Rank5))
        meld.cards.append(Card.getCard(suit: Suit.Heart, rank: Rank.Rank5))
        meld.cards.append(Card.getCard(suit: Suit.Diamond, rank: Rank.Rank5))
        XCTAssertEqual(0, meld.numberOfWildCards())
        XCTAssertEqual(5, meld.naturalValue())
        XCTAssertFalse(meld.canAddCard(card: Card.getCard(suit: Suit.Diamond, rank: Rank.Rank4))) // Not a 5, can't add
        XCTAssertTrue(meld.isARedMeld()) // No wild cards yet
        XCTAssertFalse(meld.isABook())
        let wild1 = Card.getCard(suit: Suit.Diamond, rank: Rank.RankJoker)
        XCTAssertTrue(meld.canAddCard(card: wild1)) // 4 natural cards + 1 wild is okay
        meld.cards.append(wild1)
        XCTAssertEqual(1, meld.numberOfWildCards())
        XCTAssertFalse(meld.isABook()) // Still not a Book
        let wild2 = Card.getCard(suit: Suit.Heart, rank: Rank.Rank2)
        XCTAssertTrue(meld.canAddCard(card: wild2)) // 4 natural cards + 2 wild is okay
        meld.cards.append(wild2)
        XCTAssertEqual(2, meld.numberOfWildCards())
        XCTAssertFalse(meld.isABook()) // Still not a Book
        
        let wild3 = Card.getCard(suit: Suit.Diamond, rank: Rank.Rank2)
        XCTAssertTrue(meld.canAddCard(card: wild3)) // 4 natural cards + 3 wild is okay
        meld.cards.append(wild3)
        XCTAssertEqual(3, meld.numberOfWildCards())
        XCTAssertTrue(meld.isABook()) // Now we have a Book
        
        let wild4 = Card.getCard(suit: Suit.Diamond, rank: Rank.RankJoker)
        XCTAssertFalse(meld.canAddCard(card: wild4)) // 4 natural cards + 4 wild is *NOT* okay
    }
    
    func testHandAndFoot() throws {
        var game: HandAndFoot = HandAndFoot()
        
        XCTAssertEqual(0, game.currentRound)
        XCTAssertEqual(0, game.currentDealerPlayerIndex)
        XCTAssertEqual(0, game.currentPlayerIndex)
        XCTAssertEqual(0, game.players.count)
        XCTAssertEqual(0, game.cardDeck.count)
        XCTAssertEqual(0, game.cardDiscardPile.count)
        XCTAssertEqual(0, game.cardStockPile.count)
        
        // Now initialize the game and test some functionality
        do {
            try game.initializeGame()
        } catch {
            XCTFail("Unexpected error")
        }
        
        XCTAssertEqual(Settings.currentSettings().numberOfPlayersCPU + Settings.currentSettings().numberOfPlayersHuman, game.players.count)
        XCTAssertEqual(1, game.currentRound)
        for aPlayer in game.players {
            XCTAssertEqual(Settings.currentSettings().rounds[game.currentRound].numberOfCardsPerHandFoot, aPlayer.hand.count)
            XCTAssertEqual(Settings.currentSettings().rounds[game.currentRound].numberOfCardsPerHandFoot, aPlayer.foot.count)
        }
        
        // Attempt to discard before drawing: error expected
        do {
            try game.discardCard(card: game.currentPlayer.hand[0])
            XCTFail("Should not be here was expecting GamePlayError.playerHasToDrawBeforeDiscarding")
        } catch GamePlayError.playerHasToDrawBeforeDiscarding {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error")
        }

        // Let current player take a turn, draw 2 cards from stock piles
        let currentPlayer = game.currentPlayer
        var origHandCount = currentPlayer.hand.count
        XCTAssertTrue(game.cardStockPile.count > 0)
        XCTAssertEqual(Settings.currentSettings().numberOfStockPiles, game.cardStockPile.count)
        do {
            try game.drawStockPile(firstStockPile: 0, secondStockPile: game.cardStockPile.count - 1)
        } catch {
            XCTFail("Unexpected error")
        }
        // An attempt to draw again in the same turn should fail
        do {
            try game.drawStockPile(firstStockPile: game.cardStockPile.count - 1, secondStockPile: 0)
            XCTFail("Should not be here was expecting GamePlayError.playerHasAlreadyDrawnThisTurn")
        } catch GamePlayError.playerHasAlreadyDrawnThisTurn {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error")
        }
        
        // Now that we have drawn we should be able to discard, but first
        // attempt to discard a card the player does not have in their deck, this should error out
        let cardOnlyInFoot = game.currentPlayer.foot[0]
        var indexToRemove = [Int]()
        // Make sure this card does not exist in hand
        for index in 0..<game.currentPlayer.hand.count {
            if game.currentPlayer.hand[index].value == cardOnlyInFoot.value {
                indexToRemove.append(index)
            }
        }
        for index in indexToRemove.reversed() {
            game.currentPlayer.hand.remove(at: index)
            origHandCount -= 1 // subtract from original count
        }
        do {
            try game.discardCard(card: cardOnlyInFoot)
            XCTFail("Should not be here was expecting GamePlayError.discardCardNotInPlayersDeck")
        } catch GamePlayError.discardCardNotInPlayersDeck {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error")
        }
        
        // Now discard a Card they actually have in their hand
        do {
            try game.discardCard(card: game.currentPlayer.hand[0])
        } catch {
            XCTFail("Unexpected error")
        }
        
        // Current player should be different now
        XCTAssertNotIdentical(currentPlayer, game.currentPlayer)
        // Original current player should have 1 more card than before: drew 2 new cards but discarded 1 so +1
        XCTAssertEqual(origHandCount + 1, currentPlayer.hand.count)
    }
    
    func testHandAndFootGame() throws {
        let game: HandAndFootGame = HandAndFootGame()
        
        // Now initialize the game and test some functionality
        do {
            try game.initializeGame()
        } catch {
            XCTFail("Unexpected error")
        }
        // Make sure there are at least 2 teams
        XCTAssertTrue(game.getTeams().count > 1)
        // Let's load up player one's hand with some cards to simulate some things
        for _ in 1...10 {
            game.getCurrentPlayer().hand.removeLast()
        }
        // Now add 10 cards of our choice
        // 3 Jokers
        game.getCurrentPlayer().hand.append(Card.getCard(suit: Suit.Diamond, rank: Rank.RankJoker))
        game.getCurrentPlayer().hand.append(Card.getCard(suit: Suit.Spade, rank: Rank.RankJoker))
        game.getCurrentPlayer().hand.append(Card.getCard(suit: Suit.Club, rank: Rank.RankJoker))
        // 2 4s
        game.getCurrentPlayer().hand.append(Card.getCard(suit: Suit.Diamond, rank: Rank.Rank4))
        game.getCurrentPlayer().hand.append(Card.getCard(suit: Suit.Heart, rank: Rank.Rank4))
        // 2 Aces
        game.getCurrentPlayer().hand.append(Card.getCard(suit: Suit.Heart, rank: Rank.RankAce))
        game.getCurrentPlayer().hand.append(Card.getCard(suit: Suit.Spade, rank: Rank.RankAce))
        // 2 9s
        game.getCurrentPlayer().hand.append(Card.getCard(suit: Suit.Diamond, rank: Rank.Rank9))
        game.getCurrentPlayer().hand.append(Card.getCard(suit: Suit.Club, rank: Rank.Rank9))

        let points = game.getCurrentPlayer().getPointsInCurrentHand(targetPoints: 200, addlCards: [Card]())
        // Should be at least 200 points
        XCTAssertTrue(points >= 200)
        // Should be able to lay down, but first let's set a really high target so it fails
        XCTAssertFalse(game.getCurrentPlayer().team.hasLaidDownCurrentRound)
        do {
            try game.getCurrentPlayer().layDownCards(targetPoints: 10000)
            XCTFail("Should not be here was expecting GamePlayError.cannotLayDownNotEnoughPoints")
        } catch GamePlayError.cannotLayDownNotEnoughPoints {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error")
        }
        // Should have at least 200
        XCTAssertFalse(game.getCurrentPlayer().team.hasLaidDownCurrentRound)
        do {
            try game.getCurrentPlayer().layDownCards(targetPoints: 200)
        } catch {
            XCTFail("Unexpected error")
        }
        XCTAssertTrue(game.getCurrentPlayer().team.hasLaidDownCurrentRound)
        // Should *NOT* allow us to lay down again
        do {
            try game.getCurrentPlayer().layDownCards(targetPoints: 200)
            XCTFail("Should not be here was expecting GamePlayError.teamHasAlreadyLaidDownCurrentRound")
        } catch GamePlayError.teamHasAlreadyLaidDownCurrentRound {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error")
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
