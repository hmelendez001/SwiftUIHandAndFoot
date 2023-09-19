//
//  Settings.swift
//  HandAndFoot
//
//  Created by Helder Melendez on 7/20/23.
//

import Foundation
import SwiftUI

// All rules and terminology are from either: https://playingcarddecks.com/blogs/how-to-play/hand-and-foot-game-rules
// or https://bicyclecards.com/how-to-play/hand-and-foot
// Settings are just the game settings or rule variations being followed
struct Settings {
    var name: String = "Rochelle GA"
    // Hand and Foot uses about 5 or 6 decks of standard playing cards
    var numberOfDecks: Int = 6
    // Number of stock piles
    var numberOfStockPiles: Int = 3
    var numberOfShuffles: Int = 7
    // and is played with 2-6 players
    var numberOfPlayersCPU: Int = 3
    var numberOfPlayersHuman: Int = 1
    // If 0 or less then you pick up *all* cards from discard
    // As per https://playingcarddecks.com/blogs/how-to-play/hand-and-foot-game-rules
    // "If you take from the discard pile, you must take all of the cards
    // in the discard pile."
    // If there are less cards in the discard than min then you simply pick up all
    var numberOfMinCardsPickedFromDiscard: Int = 3
    var numberOfMinCardsPerMeld: Int = 3
    // As per https://bicyclecards.com/how-to-play/hand-and-foot
    // "A [Meld total count is] a minimum of four cards of the same rank"
    // This conincides with always having one more natural card than wild card in
    // a Black Book, e.g. for 7 cards you can have 3 wild
    var numberOfMinTotalNaturalCardsPerMeld: Int = 4
    var nameRedBook: String = "Clean"
    var nameBlackBook: String = "Dirty"
    // There is some discrepancy on whether this is allowed so leaving it as a setting
    // As per https://bicyclecards.com/how-to-play/hand-and-foot
    // "The melds should not consist of all Wild Cards"
    // But per https://playingcarddecks.com/blogs/how-to-play/hand-and-foot-game-rules
    // "Wild card books (books made from 2s and Jokers) are worth 1500 points"
    var allowWildCardBooks: Bool = false
    // Some variations allow you to have a book of all 3s, but not our version
    var allowBookOf3s: Bool = false
    // As per https://playingcarddecks.com/blogs/how-to-play/hand-and-foot-game-rules
    // A 'Book' is also known as a 'Closed Pile' meaning you typically are *not* allowed
    // to add cards to a Book but this setting allows us to override this rule
    var allowAddCardsToBook: Bool = true
    // I feel like this one is a recent Aunt Peggy rule where you cannot pick up a wild
    // card from the discard pile but maybe this comes from the following after The Deal
    // from https://bicyclecards.com/how-to-play/hand-and-foot
    // "The topmost card of the Stock pile is turned face-up as a discard pile. If it
    // turns out to be a red Three, a Deuce, or a Joker, then this card goes back into
    // the pile, and another card is drawn for the top."
    var allowPickUpWildCardFromDiscard: Bool = false
    // As per https://playingcarddecks.com/blogs/how-to-play/hand-and-foot-game-rules
    // "At the end of your turn, you must discard one card"
    // This one also feels like a recent addition so leaving as a setting
    var allowNoDiscardGoingOut: Bool = true
    // When a player's turn starts and one of the 2 cards drawn in a red 3 we typically
    // make that player keep that card, but as per https://bicyclecards.com/how-to-play/hand-and-foot
    // "The topmost card of the Stock pile is turned face-up as a discard pile. If it turns
    // out to be a red Three, a Deuce, or a Joker, then this card goes back into the pile,
    // and another card is drawn for the top." But Laster/Rochelle rules we don't play like that
    var allowDiscardOfRed3FromStock: Bool = false
    // When playing 6 players do you allow 3 players on a Team so the games progresses faster,
    // this is really just a matter of preference
    var allow3PlayersPerTeam: Bool = true
    var scoreBookValueRed: Int = 500
    var scoreBookValueBlack: Int = 300
    // If allowWildCardBooks is true above then what is the point value of such a Book
    var scoreBookValueWild: Int = 1500
    // If allowBookOf3s is true above then what is the point value of such a Book
    var scoreBookValue3s: Int = 1000
    var scoreCardJoker: Int = 50
    var scoreCard2s: Int = 20
    var scoreCardAces: Int = 20
    var scoreCardFaceCard: Int = 10
    var scoreCard10: Int = 10
    var scoreCard9: Int = 10
    var scoreCard8: Int = 10
    var scoreCard4To7: Int = 5
    var scoreCard3Black: Int = -5
    var scoreCard3Red: Int = -500
    // As per https://playingcarddecks.com/blogs/how-to-play/hand-and-foot-game-rules
    // This bonus is usually 100, but as per Aunt Peggy it's 500 bonus points
    var scoreGoingOutBonus: Int = 500
    var rounds = [
        Round(numberOfCardsPerHandFoot: 13, minPointsToLayDown: 50, minRedBooksToGoOut: 2, minBlackBooksToGoOut: 3),
        Round(numberOfCardsPerHandFoot: 13, minPointsToLayDown: 90, minRedBooksToGoOut: 2, minBlackBooksToGoOut: 3),
        Round(numberOfCardsPerHandFoot: 13, minPointsToLayDown: 120, minRedBooksToGoOut: 2, minBlackBooksToGoOut: 3),
        Round(numberOfCardsPerHandFoot: 13, minPointsToLayDown: 150, minRedBooksToGoOut: 2, minBlackBooksToGoOut: 3),
        Round(numberOfCardsPerHandFoot: 17, minPointsToLayDown: 200, minRedBooksToGoOut: 3, minBlackBooksToGoOut: 4),
    ]

    static func currentSettings() -> Settings {
        // For now just harcode the one settings values above: Rochelle, GA rules
        // TODO: allow editing and setting of multiple different settings
        let def = Settings()
        
        return def
    }
}
