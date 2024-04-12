//
//  GameWinView.swift
//  Big Win
//
//  Created by Anton on 12/4/24.
//

import SwiftUI

struct GameWinView: View {
    
    @Environment(\.presentationMode) var presMode
    
    var timeLeft: Int
    var lifesLeft: Int
    
    var body: some View {
        VStack {
            Image("you_win")
            
            let time = secondsToMinutesAndSeconds(seconds: timeLeft)
            Text("\(time.0):\(time.1)")
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
            
            Button {
                presMode.wrappedValue.dismiss()
            } label: {
                Image("btn_exit")
            }
            
        }
        .background(
            Image("win_bg")
                .resizable()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .ignoresSafeArea()
                .opacity(0.9)
        )
        .preferredColorScheme(.dark)
    }
    
    private func secondsToMinutesAndSeconds(seconds: Int) -> (Int, Int) {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return (minutes, remainingSeconds)
    }
    
}

#Preview {
    GameWinView(timeLeft: 143, lifesLeft: 12)
}
