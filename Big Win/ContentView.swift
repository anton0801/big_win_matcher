//
//  ContentView.swift
//  Big Win
//
//  Created by Anton on 11/4/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            if UserDefaults.standard.string(forKey: "l_save") != nil {
                GamesMenuN()
            } else {
                GamesMenu()
            }
        }
    }
}

#Preview {
    ContentView()
}
