//
//  Big_WinApp.swift
//  Big Win
//
//  Created by Anton on 11/4/24.
//

import SwiftUI
import AppsFlyerLib
import AppTrackingTransparency
import OneSignal
import FacebookCore
import AdSupport
import Combine

class AppDelegate: NSObject, UIApplicationDelegate, AppsFlyerLibDelegate {
    
    @objc func becomeActiveAppsNotif() {
        AppsFlyerLib.shared().start()
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { (status) in
                let userIdfaID = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                UserDefaults.standard.set(userIdfaID, forKey: "idfa_user_app")
                
                self.sendCompleteNotificationMessage(status: status == .authorized)
            }
        }
    }
    
    private func sendCompleteNotificationMessage(status: Bool) {
        NotificationCenter.default.post(name: Notification.Name("ATTrackingManagerAccepted"), object: nil, userInfo: ["data": status])
    }
    
    private func defferedDeeplinkFac() {
        AppLinkUtility.fetchDeferredAppLink { (url, error) in
            if let error = error {
            }
            if let url = url {
                UserDefaults.standard.set(url, forKey: "user_deferred_deeplink_facebook")
            }
        }
    }
    
    private func apppsIn() {
        AppsFlyerLib.shared().appsFlyerDevKey = "KxqgYKY3wpgjrzrykXpehm"
        AppsFlyerLib.shared().appleAppID = "6496434393"
        AppsFlyerLib.shared().isDebug = false
        AppsFlyerLib.shared().delegate = self
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
        NotificationCenter.default.addObserver(self, selector: #selector(becomeActiveAppsNotif),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }
    
    private func inDefAndApp() {
        defferedDeeplinkFac()
        apppsIn()
    }
    
    private func initAAllll(launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) {
        inDefAndApp()
        intttPP(launchOptions: launchOptions)
    }
    
    private func intttPP(launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) {
        OneSignal.setLogLevel(.LL_NONE, visualLevel: .LL_NONE)
        OneSignal.setLocationShared(false)
        OneSignal.initWithLaunchOptions(launchOptions)
        
        DispatchQueue.main.async {
            OneSignal.setAppId("9c8d188f-9e3d-4e75-8946-4ec201650d6c")
        }

        OneSignal.promptForPushNotifications(userResponse: { accepted in
            DispatchQueue.global().asyncAfter(deadline: .now() + 25) {
                let playerId = OneSignal.getDeviceState().userId
                UserDefaults.standard.set(playerId, forKey: "onesignal_player_id")
                let taskCompletedNotification = Notification.Name("PLAYER_ID_ONESIGNAL")
                NotificationCenter.default.post(name: taskCompletedNotification, object: nil, userInfo: ["data": playerId ?? ""])
            }
         })
        innittPPOpHan()
    }
    
    private func innittPPOpHan() {
        OneSignal.setNotificationOpenedHandler { data in
                let pushData = data.jsonRepresentation()
                            
                guard let ddaj = try? JSONSerialization.data(withJSONObject: pushData),
                      let ssssjjjs = String(data: ddaj, encoding: .utf8) else {
                    return
                }
                
                if let sesdsa = ssssjjjs.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                    let sdaw = URL(string: "https://bigwinmatcher.space/technicalPostback/v1.0/postSessionParams/\(UserDefaults.standard.string(forKey: "session_id") ?? "")?push_data=\(sesdsa)&from_push=true")
                    
                    var qwerq = URLRequest(url: sdaw!)
                    qwerq.httpMethod = "POST"
                    
                    URLSession.shared.dataTask(with: qwerq) { data, response, error in
                        guard let _ = data, error == nil else {
                            print("Error: \(error?.localizedDescription ?? "Unknown error")")
                            return
                        }
                    }.resume()
                } else {
                }
            }
    }
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        initAAllll(launchOptions: launchOptions)
        return true
    }
    
    func onAppOpenAttribution(_ data: [AnyHashable : Any]) {
    }

    func onConversionDataSuccess(_ data: [AnyHashable : Any]) {
        do {
            let appsssDaSJsss = try JSONSerialization.data(withJSONObject: data, options: [])
            if let apppsdatstr = String(data: appsssDaSJsss, encoding: .utf8) {
                UserDefaults.standard.set(apppsdatstr, forKey: "user_attr_data")
                NotificationCenter.default.post(name: Notification.Name("APPSData"), object: nil, userInfo: ["data": apppsdatstr])
            }
        } catch {
        }
    }

    func onConversionDataFail(_ error: Error) { }
    
}

@main
struct Big_WinApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDel
    
    var body: some Scene {
        WindowGroup {
            SplashView()
        }
    }
}
