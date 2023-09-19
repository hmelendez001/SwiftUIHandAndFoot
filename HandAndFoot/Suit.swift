//
//  Suit.swift
//  HandAndFoot
//
//  Created by Helder Melendez on 7/21/23.
//

import Foundation
import SwiftUI

// Enumerated card suits in order of value from club to spade
public enum Suit: Int, CaseIterable, Comparable {
    public static func < (lhs: Suit, rhs: Suit) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    case Club = 1
    case Diamond
    case Heart
    case Spade
}
