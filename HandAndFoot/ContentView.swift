//
//  ContentView.swift
//  HandAndFoot
//
//  Created by Helder Melendez on 7/20/23.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var game: HandAndFootGame = HandAndFootGame()
    @State var gameInitialized: Int = -1
    @State var round: String = "Click Deal to Begin"
    
    var body: some View {
        ZStack {
            Image("background-cloth")
                .resizable()
                .ignoresSafeArea()
                
            VStack {
                Text("Hand and Foot")
                    .font(.title3)
                    .foregroundColor(.white)
                if gameInitialized < 0 {
                    Image("logo")
                        .resizable()
                        .frame(width: 200, height: 200)
                        .aspectRatio(contentMode: .fit)
                }
                // Round and Team Books
                ScrollView {
                    GroupBox(label: Text(round)) {
                        HStack {
                            ForEach(game.getTeams()) { team in TeamView(game: game, team: team) }
                        }
                    }
                }.padding(2)
                //Spacer()
                
                // Non-Human players
                VStack {
                    if (game.players.count == 6) {
                        HPlayerView(game: game, player: game.players[3], isHuman: false)
                        //Divider()
                        VPlayerView(game: game, player1: game.players[2], player2: game.players[4], isHuman: false)
                        VPlayerView(game: game, player1: game.players[1], player2: game.players[5], isHuman: false)
                        //Divider()
                        HPlayerView(game: game, player: game.players[0], isHuman: true)
                    } else if (game.players.count == 4) {
                        HPlayerView(game: game, player: game.players[2], isHuman: false)
                        //Divider()
                        VPlayerView(game: game, player1: game.players[1], player2: game.players[3], isHuman: false)
                        //Divider()
                        HPlayerView(game: game, player: game.players[0], isHuman: true)
                    } else if (game.players.count == 2) {
                        HPlayerView(game: game, player: game.players[1], isHuman: false)
                        HPlayerView(game: game, player: game.players[0], isHuman: true)
                    }
                }
                
                Spacer()
                
                HStack {
                    Button {
                        deal()
                    } label: {
                        Text("DEAL")
                        /*Image("button")
                            .resizable()
                            .frame(width: 100, height: 35)*/
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.pink)
                    Button {
                        deal()
                    } label: {
                        Text("SETTINGS")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.pink)
                }
            }
        }
    }
    
    func deal() {
        print("+++ deal CALLED")
        if (gameInitialized < 0) {
            print("Calling game.initializeGame")
            var errorMsg: String = ""
            do {
                try game.initializeGame()
            } catch GamePlayError.invalidNumberOfPlayersExpected246(let youGaveMe) {
                errorMsg = "Invalid number of players, expected 2, 4, or 6 but you set: " + String(youGaveMe)
            } catch is GamePlayError {
                errorMsg = "Game Play Error"
            } catch {
                errorMsg = "Unknown Error"
            }
            if errorMsg.count > 0 {
                print("game.initializeGame error: " + errorMsg)
                let dialogMessage = UIAlertController(title: "Initialization Error", message: errorMsg, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default)
                dialogMessage.addAction(ok)
                //)dialogMessage.show()
                return
            }
            print("game.initializeGame returned okay.")
            gameInitialized += 1
            round = "Round: " + String(game.getCurrentRound().roundNumber + 1) + " of " + String(Settings.currentSettings().rounds.count) + " - Points Needed: " + String(game.getCurrentRound().minPointsToLayDown)
            print("current player is " + game.getCurrentPlayer().name + " and has " + String(game.getCurrentPlayer().hand.count) + " cards in their hand")
            print("current Human player is " + game.getHumanPlayer().name + " and has " + String(game.getHumanPlayer().hand.count) + " cards in their hand")
        } else {
            gameInitialized += 1
        }
    }
}

// From Coding In A Nutshell: SwiftUI Card Game with AI - A Beginner's Guide
// at https://www.youtube.com/watch?v=hJ3v6MtLGnI
struct HCardView : View {
    let card: Card
    let faceUp: Bool
    var body: some View {
        if faceUp {
            card.img
                .resizable()
                .frame(width: 60, height: 100)
            //.aspectRatio(3/4, contentMode: .fit)
        } else {
            Image("red")
                .resizable()
                .frame(width: 30, height: 50)
            //.aspectRatio(3/4, contentMode: .fit)
        }
    }
}

struct VCardView : View {
    let card: Card
    let faceUp: Bool
    let isLeft: Bool
    var body: some View {
        if faceUp {
            card.img
                .resizable()
                .rotationEffect(.degrees(isLeft ? 90 : -90))
                .frame(width: 30, height: 50)
        } else {
            Image("red")
                .resizable()
                .rotationEffect(.degrees(isLeft ? 90 : -90))
                .frame(width: 30, height: 50)
        }
    }
}

struct TeamView : View {
    let game: HandAndFootGame
    let team: Team
    var body: some View {
        GroupBox(label: Text(team.name)) {
            Text("Melds: " + String(team.melds.count))
            Text("Books: " + String(team.books.count))
        }

    }
}

struct HPlayerView : View {
    let game: HandAndFootGame
    let player: Player
    let isHuman: Bool
    var body: some View {
        // From Coding In A Nutshell: SwiftUI Card Game with AI - A Beginner's Guide
        // at https://www.youtube.com/watch?v=hJ3v6MtLGnI
        VStack {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: -76)]) {
                if isHuman {
                    ForEach(player.hand.count > 0 ? player.hand : player.foot) { card in HCardView(card: card, faceUp: isHuman)
                            .offset(y: card.selected ? -30 : 0)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    game.select(card: card, player: player)
                                }
                            }}
                } else {
                    ForEach(player.hand.count > 0 ? player.hand : player.foot) { card in HCardView(card: card, faceUp: isHuman) }
                }
            }
            HStack {
                Text(player.name + " - " + (player.hand.count > 0 ? "hand" : "foot")).foregroundColor(.white)
                if (player.hand.count > 0) {
                    VStack {
                        Image("red")
                            .resizable()
                            .frame(width: 30, height: 50)
                        //Text("foot").foregroundColor(.white)
                    }
                }
            }
        }
    }
}

struct VPlayerView : View {
    let game: HandAndFootGame
    let player1: Player
    let player2: Player
    let isHuman: Bool

    var body: some View {
        HStack {
            VStack {
                LazyVStack(spacing: -43) {
                    ForEach(player1.hand.count > 0 ? player1.hand : player1.foot) { card in VCardView(card: card, faceUp: isHuman, isLeft: true) }
                }
                HStack {
                    Text(player1.name + " - " + (player1.hand.count > 0 ? "hand" : "foot")).foregroundColor(.white)
                    if (player1.hand.count > 0) {
                        VStack {
                            Image("red")
                                .resizable()
                                .frame(width: 30, height: 50)
                            //Text("foot").foregroundColor(.white)
                        }
                    }
                }
            }
            VStack {
                LazyVStack(spacing: -43) {
                    ForEach(player2.hand.count > 0 ? player2.hand : player2.foot) { card in VCardView(card: card, faceUp: isHuman, isLeft: false) }
                }
                HStack {
                    Text(player2.name + " - " + (player2.hand.count > 0 ? "hand" : "foot")).foregroundColor(.white)
                    if (player2.hand.count > 0) {
                        VStack {
                            Image("red")
                                .resizable()
                                .frame(width: 30, height: 50)
                            //Text("foot").foregroundColor(.white)
                        }
                    }
                }
            }
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
