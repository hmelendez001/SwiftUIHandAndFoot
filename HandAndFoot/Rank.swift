//
//  Rank.swift
//  HandAndFoot
//
//  Created by Helder Melendez on 7/26/23.
//

import Foundation
import SwiftUI

// Enumerated card ranks in order of value from 2 to Joker
public enum Rank: Int, CaseIterable, Comparable {
    public static func < (lhs: Rank, rhs: Rank) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    case Rank2 = 2
    case Rank3
    case Rank4
    case Rank5
    case Rank6
    case Rank7
    case Rank8
    case Rank9
    case Rank10
    case RankJack
    case RankQueen
    case RankKing
    case RankAce
    case RankJoker
}
