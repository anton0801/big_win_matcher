//
//  GameLoseView.swift
//  Big Win
//
//  Created by Anton on 12/4/24.
//

import SwiftUI

struct GameLoseView: View {
    
    @Environment(\.presentationMode) var presMode
    
    var lifesLeft: Int
    var objectiveScore: Int
    
    var body: some View {
        VStack {
            Text("Game Over")
                .font(.custom("Lemonada-Bold", size: 50))
                .foregroundColor(.white)
            
            HStack {
                Image("life")
                    .resizable()
                    .frame(width: 42, height: 42)
                
                Text("\(lifesLeft)")
                    .font(.custom("Lemonada-Bold", size: 50))
                    .foregroundColor(.white)
            }
            
            Text("Current score: \(objectiveScore)")
                .font(.custom("Lemonada-Bold", size: 24))
                .foregroundColor(.white)
            
            Button {
                presMode.wrappedValue.dismiss()
            } label: {
                Image("btn_exit")
            }
            
        }
        .background(
            Image("lose_bg")
                .resizable()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .ignoresSafeArea()
                .opacity(0.9)
        )
        .preferredColorScheme(.dark)
    }
}

#Preview {
    GameLoseView(lifesLeft: -1, objectiveScore: 12)
}
