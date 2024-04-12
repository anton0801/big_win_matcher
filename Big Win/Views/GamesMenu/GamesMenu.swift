//
//  GamesMenu.swift
//  Big Win
//
//  Created by Anton on 12/4/24.
//

import SwiftUI

struct GamesMenu: View {
    
    @State var goToBonusActive = false
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                ScrollView(.horizontal) {
                    HStack {
                        VStack {
                            let lastActionTimestamp = UserDefaults.standard.object(forKey: "last_time_rotated_wheel") as? Date
                            let funAwailable = shouldAllowAction(lastActionTimestamp: lastActionTimestamp)
                            ZStack {
                                Image("bonus")
                                if !funAwailable {
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .fill(Color.init(red: 0, green: 0, blue: 0))
                                        .opacity(0.4)
                                        .frame(width: 248, height: 240)
                                }
                            }
                            
                            if funAwailable {
                                Button {
                                    goToBonusActive = true
                                } label: {
                                    Image("btn_take")
                                        .padding(.top)
                                }
                            } else {
                                ZStack {
                                    let timeToAccess = availableTimeForAction(lastActionTimestamp: lastActionTimestamp)
                                    Image("btn_disabled")
                                    Text("\(timeToAccess)")
                                        .font(.custom("Lemonada-SemiBold", size: 24))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .frame(width: 300)
                        .padding(.bottom)
                        
                        NavigationLink(destination: BonusGameView()
                            .navigationBarBackButtonHidden(true), isActive: $goToBonusActive) {
                            EmptyView()
                        }
                        
                        NavigationLink(destination: Game1View()
                            .navigationBarBackButtonHidden(true)) {
                            VStack {
                                Image("game_1")
                                
                                Image("btn_play")
                                    .padding(.top)
                            }
                            .frame(width: 300)
                            .padding(.bottom)
                        }
                        
                        NavigationLink(destination: Game3View()
                            .navigationBarBackButtonHidden(true)) {
                            VStack {
                                Image("game_2")
                                
                                Image("btn_play")
                                    .padding(.top)
                            }
                            .frame(width: 300)
                            .padding(.bottom)
                        }
                    }
                }
            }
            .background(
                Image("main_bg")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .ignoresSafeArea()
                    .opacity(0.9)
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func shouldAllowAction(lastActionTimestamp: Date?) -> Bool {
        guard let lastActionTimestamp = lastActionTimestamp else {
            return true
        }
        let currentDate = Date()
        let timeDifference = currentDate.timeIntervalSince(lastActionTimestamp)
        let hoursInSeconds: TimeInterval = 24 * 60 * 60
        return timeDifference >= hoursInSeconds
    }
    
    private func availableTimeForAction(lastActionTimestamp: Date?) -> String {
        guard let lastActionTimestamp = lastActionTimestamp else {
            return "Now"
        }
        let currentDate = Date()
        let timeDifference = currentDate.timeIntervalSince(lastActionTimestamp)
        let remainingTime = 24 * 60 * 60 - timeDifference
        let hours = Int(remainingTime) / 3600
        let minutes = Int(remainingTime) / 60 % 60
        let seconds = Int(remainingTime) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
}

#Preview {
    GamesMenu()
}
