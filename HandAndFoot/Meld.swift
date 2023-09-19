//
//  Meld.swift
//  HandAndFoot
//
//  Created by Helder Melendez on 7/20/23.
//

import Foundation
import SwiftUI

// All rules and terminology are from: https://playingcarddecks.com/blogs/how-to-play/hand-and-foot-game-rules
// A Meld is a pile of cards of the same
// Melds are formed by matching cards of the same rank.
// A meld must begin with at least 3 cards. Melds are
// shared within the teams so, teammates can build upon their own melds.
class Meld {
    var cards: [Card] = [Card]()
    // A Meld is owned by a Team
    let owner: Team
    
    init(owner: Team) {
        self.owner = owner
    }

    func numberOfWildCards() -> Int {
        var count = 0
        for card in cards {
            if (card.isWildCard()) {
                count += 1
            }
        }
        return count
    }

    func naturalValue() -> Int {
        for card in cards {
            if (!card.isWildCard()) {
                return card.rank.rawValue
            }
        }
        return 0
    }

    // Is it legal or valid to add the given Card to this Meld
    func canAddCard(card: Card) -> Bool {
        // If the Meld is a Book already and we are not allowing adding cards to a Book then immediately return false
        if isABook() && !Settings.currentSettings().allowAddCardsToBook {
            return false
        }
        let naturalValue = naturalValue()
        // If no other cards then yes we can add any Card
        if naturalValue == 0 {
            return true
        }
        // Must have one more natural card than wild card
        if card.isWildCard() {
            let wildCount: Int = numberOfWildCards()
            let naturalCount: Int = cards.count - wildCount
            if naturalCount > (wildCount + 1) {
                return true
            }
        } else if card.value == naturalValue {
            return true
        }
        return false
    }
    
    // If none of the cards are wild, it is called a red meld (or clean meld)
    func isARedMeld() -> Bool {
        return numberOfWildCards() == 0
    }
    
    func isABook() -> Bool {
        // In Hand and Foot, a pile of 7 cards is called a Book
        return cards.count >= 7
    }
}
