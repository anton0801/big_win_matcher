//
//  Game2View.swift
//  Big Win
//
//  Created by Anton on 18/4/24.
//

import SwiftUI
import SpriteKit

struct Game2View: View {
    
    @Environment(\.presentationMode) var presMode
    
    private var gameScene: Game2Scene {
        get {
            return Game2Scene()
        }
    }
    
    var body: some View {
        VStack {
            SpriteView(scene: gameScene)
                .ignoresSafeArea()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("TO_HOME"))) { _ in
            presMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    Game2View()
}
