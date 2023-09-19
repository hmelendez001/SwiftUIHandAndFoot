//
//  Card.swift
//  HandAndFoot
//
//  Created by Helder Melendez on 7/20/23.
//

import Foundation
import SwiftUI

// All rules and terminology are from either: https://playingcarddecks.com/blogs/how-to-play/hand-and-foot-game-rules
// or https://bicyclecards.com/how-to-play/hand-and-foot
class Card : Identifiable {
    let name: String
    let img: Image
    let value: Int
    let suit: Suit
    let rank: Rank
    var points: Int = 0
    var selected: Bool = false
    // Allows us to use ForEach
    var id = UUID()

    init(name: String, img: Image, value: Int, suit: Suit, rank: Rank) {
        self.name = name
        self.img = img
        self.value = value
        self.suit = suit
        self.rank = rank
    }
    
    public var description: String { return name }
    
    static let c:Card = Card(name: "default", img: Image("logo"), value: 0, suit: Suit.Diamond, rank: Rank.Rank3)
    
    public static func defaultCard() -> Card {
        return c
    }
    
    /*
     *     Use Settings card values to return current Card point value
     *     var scoreCardJoker: Int = 50
     *     var scoreCard2s: Int = 20
     *     var scoreCardAces: Int = 20
     *     var scoreCardFaceCard: Int = 10
     *     var scoreCard10: Int = 10
     *     var scoreCard9: Int = 10
     *     var scoreCard8: Int = 10
     *     var scoreCard4To7: Int = 5
     *     var scoreCard3Black: Int = -5
     *     var scoreCard3Red: Int = -500
     */
    func getPointValue() -> Int {
        if self.points > 0 {
            return self.points
        }
        if (isJoker()) {
            self.points = Settings.currentSettings().scoreCardJoker
        } else if (self.rank == Rank.Rank2) {
            self.points = Settings.currentSettings().scoreCard2s
        } else if (self.rank == Rank.RankAce) {
            self.points = Settings.currentSettings().scoreCardAces
        } else if (self.rank > Rank.Rank10) {
            self.points = Settings.currentSettings().scoreCardFaceCard
        } else if (self.rank == Rank.Rank10) {
            self.points = Settings.currentSettings().scoreCard10
        } else if (self.rank == Rank.Rank9) {
            self.points = Settings.currentSettings().scoreCard9
        } else if (self.rank == Rank.Rank8) {
            self.points = Settings.currentSettings().scoreCard8
        } else if (self.rank > Rank.Rank3) {
            self.points = Settings.currentSettings().scoreCard4To7
        } else {
            // 3s
            if (isRedCard()) {
                self.points = Settings.currentSettings().scoreCard3Red
            } else {
                self.points = Settings.currentSettings().scoreCard3Black
            }
        }

        return self.points
    }

    // The Jokers and 2s in the deck are wildcards and can be used to build upon any Meld
    func isWildCard() -> Bool {
        // Jokers and 2s are wild
        return self.rank == Rank.RankJoker || self.rank == Rank.Rank2
    }
    
    func isRedCard() -> Bool {
        return self.suit == Suit.Diamond || self.suit == Suit.Heart
    }
    
    func is3Card() -> Bool {
        return self.rank == Rank.Rank3
    }
    
    func isJoker() -> Bool {
        return self.rank == Rank.RankJoker
    }
    
    func isNaturalMatch(card: Card) -> Bool {
        // Check that the given Card is a natural match to self, e.g. card and self are both 4's or both J's etc.
        return self.rank.rawValue == card.rank.rawValue
    }
    
    // Create a Card object based on given Suit and index between 2 and 15
    public static func getCard(suit: Suit, rank: Rank) -> Card {
        var name = String(rank.rawValue)
        let value = rank.rawValue * 10 + suit.rawValue
        var imgName = "card" + (value < 100 ? "0" : "") + String(value)
        if (rank.rawValue > 10) {
            // Handle face cards
            if rank == Rank.RankJack {
                name = "J"
            } else if rank == Rank.RankQueen {
                name = "Q"
            } else if rank == Rank.RankKing {
                name = "K"
            } else if rank == Rank.RankAce {
                name = "A"
            } else {
                name = "Joker"
            }
        }
        // Only for non-Jokers
        if rank != Rank.RankJoker {
            name = name + " of " + "\(suit)s"
        } else {
            // Jokers do not really have a suit just black (Spade or Club) or red (Heart or Diamond)
            var mysuit = suit
            if suit == Suit.Heart {
                mysuit = Suit.Diamond
            } else if suit == Suit.Spade {
                mysuit = Suit.Club
            }
            imgName = "card" + String(rank.rawValue * 10 + mysuit.rawValue)
        }
        let img = Image(imgName)
        let card: Card = Card(name: name, img: img, value: value, suit: suit, rank: rank)

        return card
    }
}
