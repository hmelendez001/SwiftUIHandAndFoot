//
//  Round.swift
//  HandAndFoot
//
//  Created by Helder Melendez on 7/20/23.
//

import Foundation
import SwiftUI

// All rules and terminology are from either: https://playingcarddecks.com/blogs/how-to-play/hand-and-foot-game-rules
// or https://bicyclecards.com/how-to-play/hand-and-foot
// Each game consist of N number of Rounds or plays
// A Round is over when a player "goes out" or has not more cards left in either
// their Hand or their Foot set of Cards
// A Game has N Rounds as determined by Settings.rounds
// Within each Round each Player takes a turn which involves drawing from the stock pile or the discard pile, taking some action
// like laying down if the Team has not laid down cards, putting down new Melds, or adding to existing Melds
// The player turn ends when they discard to the discard pile unless it is their foot going out as determined by Settings.allowNoDiscardGoingOut
struct Round {
    var roundNumber: Int = 0
    // As per https://bicyclecards.com/how-to-play/hand-and-foot
    // "Each player is dealt 11 cards"
    var numberOfCardsPerHandFoot: Int = 11
    var minPointsToLayDown: Int
    // As per https://playingcarddecks.com/blogs/how-to-play/hand-and-foot-game-rules
    // "Teams must have made a red book and a black book before they
    // are allowed to 'go out'" but this varies via Settings
    var minRedBooksToGoOut: Int = 1
    var minBlackBooksToGoOut: Int = 1
}
