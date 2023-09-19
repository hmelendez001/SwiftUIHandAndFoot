//
//  GamePlayError.swift
//  HandAndFoot
//
//  Created by Helder Melendez on 7/23/23.
//

import Foundation
import SwiftUI

enum GamePlayError : Error {
    case invalidNumberOfPlayersExpected246(youGaveMe: Int)
    case invalidFirstStockPileNumber(youGaveMe: Int)
    case invalidSecondStockPileNumber(youGaveMe: Int)
    case emptyFirstStockPileNumber(youGaveMe: Int)
    case emptySecondStockPileNumber(youGaveMe: Int)
    case discardPileIsEmpty
    case discardPileCannotPickUpWildCard
    case discardPileCannotPickUp3Card
    case discardPilePlayerCannotMeldWithTopCard
    case discardPileCannotPickUpNotEnoughPointsToLayDown(needPoints: Int, hasPoints: Int)
    case cannotLayDownNotEnoughPoints(needPoints: Int, hasPoints: Int)
    case notEnoughCardsForMatchingMeld
    case playerHasToDrawBeforeDiscarding
    case playerHasAlreadyDrawnThisTurn
    case discardCardNotInPlayersDeck
    case teamHasAlreadyLaidDownCurrentRound
}
