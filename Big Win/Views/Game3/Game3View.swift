//
//  Game3View.swift
//  Big Win
//
//  Created by Anton on 11/4/24.
//

import SwiftUI
import SpriteKit

struct Game3View: View {
    
    @State var gameOver = false
    @State var gameWin = false
    @State var lifesLeft = 0
    @State var timeLeft = 0
    @State var objectiveScore = 0
    @State var gameId = ""
    
    private var gameScene: Game3Scene {
        get {
            return Game3Scene()
        }
    }

    var body: some View {
        if gameOver {
            GameLoseView(lifesLeft: lifesLeft, objectiveScore: objectiveScore)
        } else if gameWin {
            GameWinView(timeLeft: timeLeft, lifesLeft: lifesLeft)
        } else {
            VStack {
                SpriteView(scene: gameScene)
                    .ignoresSafeArea()
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("GAMA_OVER"))) { notification in
                if let objectiveScore = notification.userInfo?["objectiveScore"] as? Int,
                    let gameId = notification.userInfo?["gameId"] as? String,
                    let lifes = notification.userInfo?["lifes"] as? Int,
                    let timeLeft = notification.userInfo?["timeLeft"] as? Int {
                        if gameId != self.gameId {
                            self.objectiveScore = objectiveScore
                            self.gameId = gameId
                            self.timeLeft = timeLeft
                            self.lifesLeft = lifes
                            withAnimation {
                                gameOver = true
                            }
                        }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("GAME_WIN"))) { notification in
                if let objectiveScore = notification.userInfo?["objectiveScore"] as? Int,
                    let gameId = notification.userInfo?["gameId"] as? String,
                    let lifes = notification.userInfo?["lifes"] as? Int,
                    let timeLeft = notification.userInfo?["timeLeft"] as? Int {
                        if gameId != self.gameId {
                            self.objectiveScore = objectiveScore
                            self.gameId = gameId
                            self.timeLeft = timeLeft
                            self.lifesLeft = lifes
                            withAnimation {
                                gameWin = true
                            }
                        }
                }
            }
        }
    }
}

#Preview {
    Game3View()
}
