//
//  BonusGameView.swift
//  Big Win
//
//  Created by Anton on 12/4/24.
//

import SwiftUI

struct BonusGameView: View {
    
    @State private var rotationAngle: Double = 0
    @State private var result: String = ""
    
    let sectorValues = [15, 30, 20, 15, 10, 20, 15, 20, 10, 15, 10, 30]
    let numberOfSectors = 12
    
    @Environment(\.presentationMode) var presMode
    
    @State private var bonusBack = "bonus_bg"
    @State private var winBonus = false
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    presMode.wrappedValue.dismiss()
                } label: {
                    Image("ic_home")
                }
            }
            .padding(.trailing)
            Spacer()
            
            ZStack {
                Image("roulette_border")
                
                Image("roulette")
                    .rotationEffect(.degrees(rotationAngle))
                    .animation(.easeInOut(duration: 5.0))
                
                Image("roulette_indicator")
                    .offset(y: -140)
            }
            .padding(.top, 150)
            
            Button {
                if !winBonus {
                    withAnimation {
                        let randomRotation = 360 * 9.0
                        rotationAngle += randomRotation
                        
                        let sectorIndex = 0
                        let sectorValue = sectorValues[sectorIndex]
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            withAnimation {
                                bonusBack = "bonus_win"
                                winBonus = true
                            }
                        }
                    }
                } else {
                    UserDefaults.standard.set(Date(), forKey: "last_time_rotated_wheel")
                    presMode.wrappedValue.dismiss()
                }
            } label: {
                if !winBonus {
                    Image("btn_spin")
                        .padding(.top, 30)
                } else {
                    Image("btn_take")
                        .padding(.top, 30)
                }
            }
            
            Spacer()
        }
        .background(
            Image(bonusBack)
                .resizable()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .ignoresSafeArea()
                .opacity(0.9)
        )
    }
}

#Preview {
    BonusGameView()
}
