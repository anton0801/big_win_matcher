//
//  Game1View.swift
//  Big Win
//
//  Created by Anton on 12/4/24.
//

import SwiftUI
import SpriteKit
import SwiftyJSON
import WebKit

struct Game1View: View {
    
    @Environment(\.presentationMode) var presMode
    
    @State var gameOver = false
    @State var gameWin = false
    @State var lifesLeft = 0
    @State var timeLeft = 0
    @State var objectiveScore = 0
    @State var gameId = ""
    
    private var gameScene: Game1Scene {
        get {
            return Game1Scene()
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
                    .onReceive(NotificationCenter.default.publisher(for: Notification.Name("TO_HOME"))) { _ in
                        presMode.wrappedValue.dismiss()
                    }
            }
        }
    }
}

struct OneQuesGamCandie: Codable {
    var appsflyer: JSON
    var facebook_deeplink: String
}

struct TwoQuesCandie: Decodable {
    var client_id: String
    var session_id: String
    var offer_id: Int?
    var response: String?
    var message: String?
    var product: String?
    var saved_url: Bool?
}

extension Dictionary {
    func jsonData() throws -> Data {
        try JSONSerialization.data(withJSONObject: self)
    }
}


class GameMenuUtils : ObservableObject {
    @Published var gamesViews : [WKWebView] = []
    @Published var cookies: [HTTPCookie] = []
}

extension Notification.Name {
    static let goBackNotification = Notification.Name("goBackNotification")
    static let reloadNotification = Notification.Name("reloadNotification")
}

#Preview {
    Game1View()
}
