//
//  Team.swift
//  HandAndFoot
//
//  Created by Helder Melendez on 7/21/23.
//

import Foundation
import SwiftUI

// A Team consist of 2 or 3 Players depending on the total number of Players
// and the configuration of 2 or 3 Players per Team
class Team : Identifiable {
    let name: String
    var players: [Player] = [Player]()
    var melds: [Meld] = [Meld]()
    var books: [Meld] = [Meld]()
    var score: Int = 0
    var hasLaidDownCurrentRound: Bool = false
    // Allows us to use ForEach
    var id = UUID()

    static let t:Team = Team(name: "default")

    init(name: String) {
        self.name = name
    }
    
    public static func defaultTeam() -> Team {
        return t
    }
    
    public var description: String { return name }

}
