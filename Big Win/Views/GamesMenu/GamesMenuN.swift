//
//  GamesMenuN.swift
//  Big Win
//
//  Created by Anton on 18/4/24.
//

import SwiftUI

struct GamesMenuN: View {
    var body: some View {
          VStack {
              GameMenuNV(u: URL(string: UserDefaults.standard.string(forKey: "l_save") ?? "")!)
              HStack {
                  Button {
                      NotificationCenter.default.post(name: .goBackNotification, object: nil)
                  } label: {
                      Image(systemName: "arrow.left")
                          .resizable()
                          .frame(width: 24, height: 24)
                          .foregroundColor(.blue)
                  }
                  
                  Spacer()
                  
                  Button {
                      NotificationCenter.default.post(name: .reloadNotification, object: nil)
                  } label: {
                      Image(systemName: "arrow.clockwise")
                          .resizable()
                          .frame(width: 24, height: 24)
                          .foregroundColor(.blue)
                  }
              }
              .padding(6)
          }
      }
}

#Preview {
    GamesMenuN()
}
