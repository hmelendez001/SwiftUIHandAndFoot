//
//  Player.swift
//  HandAndFoot
//
//  Created by Helder Melendez on 7/20/23.
//

import Foundation
import SwiftUI

// All rules and terminology are from: https://playingcarddecks.com/blogs/how-to-play/hand-and-foot-game-rules
// A Player can be human or CPU and must have a partner, so we expect even # of Players
class Player {
    let name: String
    let isHuman: Bool
    var playerHasDrawnThisTurn: Bool = false
    var playerHasDiscardedThisTurn: Bool = false
    var team: Team = Team.defaultTeam()
    var hand: [Card] = [Card]()
    var foot: [Card] = [Card]()
    // Allows us to use ForEach
    var id = UUID()

    init(name: String, isHuman: Bool) {
        self.name = name
        self.isHuman = isHuman
    }
    
    static let p:Player = Player(name: "", isHuman: false)
    
    public static func defaultPlayer() -> Player {
        return p
    }
    
    public var description: String { return name }

    // Given an optional set of cards to include in the count, e.g. from discard pile, return number of points in current hand
    // The given target points are to let us dirty up a Meld if we are short on target points
    func getPointsInCurrentHand(targetPoints: Int, addlCards: [Card]) -> Int {
        let resp = getMelds(targetPoints: targetPoints, addlCards: addlCards)
        
        return resp.points
    }
    
    private func getMelds(targetPoints: Int, addlCards: [Card]) -> (melds: [Meld], points: Int) {
        // Create a map of same suitValue cards, e.g all 4s, 5s, etc.
        var hash = Dictionary<Rank, [Card]>()
        
        // Track wild cards separately to see if we can get a dirty meld, if needed
        var wildCards2 = [Card]()
        // Prioritize Joker wild cards for dirty melds as Jokers have higher point value
        var wildCardsJ = [Card]()
        
        var targetDeck: [Card] = [Card]()
        if (addlCards.count == 0) {
            targetDeck = self.hand
        } else {
            for aCard in self.hand {
                targetDeck.append(aCard)
            }
            for aCard in addlCards {
                targetDeck.append(aCard)
            }
        }

        // The targetDeck is either the hand or the foot and additional cards being considered like the discard pile
        for aCard in targetDeck {
            // If book of 3s is not allowed then skip 3 cards
            if aCard.is3Card() && !Settings.currentSettings().allowBookOf3s {
                continue
            }
            if aCard.isWildCard() {
                if aCard.isJoker() {
                    wildCardsJ.append(aCard)
                } else {
                    wildCards2.append(aCard)
                }
                continue
            }
            if hash[aCard.rank] != nil {
                hash[aCard.rank]?.append(aCard)
            } else {
                var newcards = [Card]()
                newcards.append(aCard)
                hash[aCard.rank] = newcards
            }
        }
        
        // Now let's build the Melds
        var melds: [Meld] = [Meld]()
        var points: Int = 0
        for aSuitValue in hash.keys {
            // Start with clean or natural card melds
            if let cards = hash[aSuitValue] {
                if cards.count >= Settings.currentSettings().numberOfMinCardsPerMeld {
                    // We have a Meld, if the cardcount is >= numberOfMinCardsPerMeld * 2, we'll create 2 Melds
                    if (cards.count >= (2 * Settings.currentSettings().numberOfMinCardsPerMeld)) {
                        
                    } else {
                        let aMeld = Meld(owner: self.team)
                        for aCard in cards {
                            aMeld.cards.append(aCard)
                            points += aCard.getPointValue()
                        }
                        melds.append(aMeld)
                    }
                } else if cards.count == (Settings.currentSettings().numberOfMinCardsPerMeld - 1) {
                    // Short 1 Card for a Meld but we have a wild card to dirty it
                    var wildCard: Card
                    // Start with higher point Joker wild cards, if available
                    if (wildCardsJ.count > 0) {
                        wildCard = wildCardsJ.removeLast()
                    } else if (wildCards2.count > 0) {
                        wildCard = wildCards2.removeLast()
                    } else {
                        continue
                    }
                    let aMeld = Meld(owner: self.team)
                    for aCard in cards {
                        aMeld.cards.append(aCard)
                        points += aCard.getPointValue()
                    }
                    aMeld.cards.append(wildCard)
                    points += wildCard.getPointValue()
                    melds.append(aMeld)
                }
            }
        }
        // If we are short points then "dirty" up a red/clean book
        while (points < targetPoints && (wildCardsJ.count + wildCards2.count) > 0) {
            var wildCard: Card
            // Start with higher point Joker wild cards, if available
            if (wildCardsJ.count > 0) {
                wildCard = wildCardsJ.removeLast()
            } else {
                wildCard = wildCards2.removeLast()
            }
            for aMeld in melds {
                if aMeld.canAddCard(card: wildCard) {
                    aMeld.cards.append(wildCard)
                    points += wildCard.getPointValue()
                    break
                }
            }
        }
        
        return (melds, points)
    }
    
    // Lay down current hand points
    func layDownCards(targetPoints: Int) throws {
        if self.team.hasLaidDownCurrentRound {
            throw GamePlayError.teamHasAlreadyLaidDownCurrentRound
        }
        let resp = getMelds(targetPoints: targetPoints, addlCards: [Card]())
        let melds = resp.melds
        let points = resp.points

        if (points < targetPoints) {
            throw GamePlayError.cannotLayDownNotEnoughPoints(needPoints: targetPoints, hasPoints: points)
        }
        
        for aMeld in melds {
            for aCard in aMeld.cards {
                if let index = self.hand.firstIndex(where: {$0.value == aCard.value}) {
                    self.hand.remove(at: index)
                }
            }
            self.team.melds.append(aMeld)
        }
        self.team.hasLaidDownCurrentRound = true
    }
    
    // Lay down a Meld that matches topCard
    func layDownMeld(topCard: Card) throws {
        let meld = Meld(owner: self.team)
        for aCard in hand.count == 0 ? foot : hand {
            // Just natural cards here, later the player may decide to add wild cards if so desired
            if topCard.isNaturalMatch(card: aCard) {
                meld.cards.append(aCard)
            }
        }
        if (meld.cards.count + 1) < Settings.currentSettings().numberOfMinCardsPerMeld {
            throw GamePlayError.notEnoughCardsForMatchingMeld
        }
        // Remove the cards to Meld
        for aCard in meld.cards {
            if let index = hand.count == 0 ? foot.firstIndex(where: {$0.value == aCard.value}) : hand.firstIndex(where: {$0.value == aCard.value}) {
                if hand.count == 0 {
                    foot.remove(at: index)
                } else {
                    hand.remove(at: index)
                }
            }
        }
        meld.cards.append(topCard)
        // Add the Meld to the Team melds
        self.team.melds.append(meld)
    }
    
    func addCardToCurrentDeck(card: Card) {
        // Assume if hand is empty then player must be in their foot
        if (hand.count == 0) {
            foot.append(card)
        } else {
            hand.append(card)
        }
    }
    
    func canMeldWithThisCard(card: Card) -> Bool {
        // Given a Card, probably the top Card from the discard pile does the player have two other cards to make a Meld with this one?
        var retVal: Bool = false
        // Assume if hand is empty then player must be in their foot
        var meldCount: Int = 0
        var deckToCheck: [Card] = hand
        if (hand.count == 0) {
            deckToCheck = foot
        }
        for cardInDeck in deckToCheck {
            if cardInDeck.isNaturalMatch(card: card) {
                meldCount += 1
            }
        }
        if meldCount >= 2 {
            retVal = true
        }
        return retVal
    }
    
    func discardCard(card: Card) -> Card {
        var retVal: Card = Card.defaultCard()
        if let index = hand.count == 0 ? foot.firstIndex(where: {$0.value == card.value}) : hand.firstIndex(where: {$0.value == card.value}) {
            if hand.count == 0 {
                retVal = foot.remove(at: index)
            } else {
                retVal = hand.remove(at: index)
            }
        }
        return retVal
    }
    
    static func setDefaultPlayers(_ players: inout [Player]) -> [Team] {
        for count in 1...Settings.currentSettings().numberOfPlayersHuman {
            players.append(Player(name: "Helder" + (count > 1 ? String(count) : ""), isHuman: true))
        }
        for count in 1...Settings.currentSettings().numberOfPlayersCPU {
            players.append(Player(name: "CPU" + String(count), isHuman: false))
        }
        // Assign Teams now that we have an array of players
        // We can only have either 4 or 6 players, and either 2 or 3 Teams depending on Settings
        var teams = [Team]()
        teams.append(Team(name: "Team 1"))
        teams.append(Team(name: "Team 2"))
        
        if (players.count == 4) {
            //     2
            //     ↑
            // 1   |   3
            //     ↓
            //     0
            players[0].team = teams[0]
            players[2].team = teams[0]
            teams[0].players = [ players[0], players[2] ]
            //     2
            //
            // 1 ← - → 3
            //
            //     0
            players[1].team = teams[1]
            players[3].team = teams[1]
            teams[1].players = [ players[1], players[3] ]
        } else if (players.count == 6) {
            // If we allow 3 Players per Team then 2 Teams is enough, otherwise, add a 3rd Team
            if (Settings.currentSettings().allow3PlayersPerTeam) {
                // Even numbers on Team 1
                //     3
                //
                // 2 ← - → 4
                //     |
                // 1   |   5
                //     ↓
                //     0
                players[0].team = teams[0]
                players[2].team = teams[0]
                players[4].team = teams[0]
                teams[0].players = [ players[0], players[2], players[4] ]
                // Odd numbers on Team 2
                //     3
                //     ↑
                // 2   |   4
                //     |
                // 1 ← - → 5
                //
                //     0
                players[1].team = teams[1]
                players[3].team = teams[1]
                players[5].team = teams[1]
                teams[1].players = [ players[1], players[3], players[5] ]
            } else {
                teams.append(Team(name: "Team 3"))
                // Players 0 and 3 on Team 1
                //     3
                //     ↑
                // 2   |   4
                //     |
                // 1   |   5
                //     ↓
                //     0
                players[0].team = teams[0]
                players[3].team = teams[0]
                teams[0].players = [ players[0], players[3] ]
                // Players 1 and 5 on Team 2
                //     3
                //
                // 2       4
                //
                // 1 ← - → 5
                //
                //     0
                players[1].team = teams[1]
                players[5].team = teams[1]
                teams[1].players = [ players[1], players[5] ]
                // Players 2 and 4 on Team 3
                //     3
                //
                // 2 ← - → 4
                //
                // 1       5
                //
                //     0
                players[2].team = teams[2]
                players[4].team = teams[2]
                teams[2].players = [ players[2], players[4] ]
            }
        }
        return teams
    }
}
