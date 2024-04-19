//
//  InfoGamesView.swift
//  Big Win
//
//  Created by Anton on 18/4/24.
//

import SwiftUI

struct InfoGamesView: View {
    
    @Environment(\.presentationMode) var presMode
    
    var selectedTab: Int
    
    @State private var selected = 0
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                Text("Rules")
                    .font(.custom("Lemonada-Bold", size: 32))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button {
                    presMode.wrappedValue.dismiss()
                } label: {
                    Image("ic_home")
                }
            }
            .padding([.leading, .trailing])
            
            ScrollView(.horizontal) {
                HStack {
                    Button {
                        selected = 0
                    } label: {
                        ZStack {
                            if selected == 0 {
                                Image("info_btn_bg_selected")
                            } else {
                                Image("info_btn_bg")
                            }
                            
                            Text("Bonus")
                                .font(.custom("Lemonada-Bold", size: 18))
                                .foregroundColor(.white)
                        }
                    }
                    
                    Button {
                        selected = 1
                    } label: {
                        ZStack {
                            if selected == 1 {
                                Image("info_btn_bg_selected")
                            } else {
                                Image("info_btn_bg")
                            }
                            
                            Text("Connector")
                                .font(.custom("Lemonada-Bold", size: 16))
                                .foregroundColor(.white)
                        }
                    }
                    
                    Button {
                        selected = 2
                    } label: {
                        ZStack {
                            if selected == 2 {
                                Image("info_btn_bg_selected")
                            } else {
                                Image("info_btn_bg")
                            }
                            
                            Text("Catcher")
                                .font(.custom("Lemonada-Bold", size: 18))
                                .foregroundColor(.white)
                        }
                    }
                    
                    Button {
                        selected = 3
                    } label: {
                        ZStack {
                            if selected == 3 {
                                Image("info_btn_bg_selected")
                            } else {
                                Image("info_btn_bg")
                            }
                            
                            Text("Builder")
                                .font(.custom("Lemonada-Bold", size: 18))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            
            Spacer()
            
            VStack {
                Text(rulesData[selected])
                    .font(.custom("Lemonada-Bold", size: 16))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.purple)
            )
            .padding()
            
            Spacer()
        }
        .background(
            Image("main_bg")
                .resizable()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .ignoresSafeArea()
                .opacity(0.9)
        )
        .onAppear {
            selected = selectedTab
        }
    }
}

#Preview {
    InfoGamesView(selectedTab: 0)
}
