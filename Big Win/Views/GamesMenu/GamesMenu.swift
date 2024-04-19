//
//  GamesMenu.swift
//  Big Win
//
//  Created by Anton on 12/4/24.
//

import SwiftUI
import WebKit

struct GamesMenu: View {
    
    @State var goToBonusActive = false
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Spacer()
                    NavigationLink(destination: InfoGamesView(selectedTab: 0).navigationBarBackButtonHidden(true)) {
                        Image("info_btn")
                    }
                }
                .padding(.trailing)
                
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
                        
                        NavigationLink(destination: Game2View()
                            .navigationBarBackButtonHidden(true)) {
                            VStack {
                                Image("game_3")
                                
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

struct GameMenuNV: UIViewRepresentable {
    let u: URL
        
    @State var gameMenUtil = GameMenuUtils()

    @State var webView: WKWebView = WKWebView()
    @State var webViews : [WKWebView] = []

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var par: GameMenuNV

        init(parent: GameMenuNV) {
            self.par = parent
        }
        
        @objc func handleNotification(_ notification: Notification) {
            if notification.name == .goBackNotification {
                par.goBack()
            } else if notification.name == .reloadNotification {
                par.refresh()
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            NotificationCenter.default.addObserver(self, selector: #selector(handleNotification), name: .goBackNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(handleNotification), name: .reloadNotification, object: nil)
        }
        
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                completionHandler()
            }))
            UIApplication.shared.windows.first?.rootViewController?.present(alertController, animated: true, completion: nil)
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            
            if let url = navigationAction.request.url {
                let urlString = url.absoluteString
                if urlString.hasPrefix("tg://") || urlString.hasPrefix("viber://") || urlString.hasPrefix("whatsapp://") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    decisionHandler(.cancel)
                    return
                }
            }
            
            decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
            guard let currentURL = webView.url else {
                return
            }
            
            let cookies: WKHTTPCookieStore? = webView.configuration.websiteDataStore.httpCookieStore
            var cookiesList: [String: [String: HTTPCookie]] = [:]
            let userDefaults = UserDefaults.standard
            
            if let cooksadda: [String: [String: [HTTPCookiePropertyKey: AnyObject]]]? = (userDefaults.dictionary(forKey: "cookiesKey") ?? [:]) as [String: [String: [HTTPCookiePropertyKey: AnyObject]]] {
                for (domain, cookieMap) in cooksadda ?? [:] {
                    var mpaOfDoma = cookiesList[domain] ?? [:]
                    for (_, cookie) in cookieMap {
                        if let cookie: [HTTPCookiePropertyKey: AnyObject]? = cookie as [HTTPCookiePropertyKey: AnyObject] {
                            if cookie != nil {
                                let cookieValue = HTTPCookie(properties: cookie!)
                                mpaOfDoma[cookieValue!.name] = cookieValue
                            }
                        }
                    }
                    cookiesList[domain] = mpaOfDoma
                }
            }
            if let cookies = cookies {
                cookies.getAllCookies { cookies in
                    for cookie in cookies {
                        var mapCookiesOfDomain = cookiesList[cookie.domain] ?? [:]
                        mapCookiesOfDomain[cookie.name] = cookie
                        cookiesList[cookie.domain] = mapCookiesOfDomain
                    }
                    self.sssaacoooksa(cookies: cookiesList)
                }
            }
        }
        
        private func sssaacoooksa(cookies: [String: [String: HTTPCookie]]) {
            let userDefaults = UserDefaults.standard

            var cookieDict = [String : [String: AnyObject]]()

            for (domain, cookieMap) in cookies {
                var mapParent = cookieDict[domain] ?? [:]
                for (_, cookie) in cookieMap {
                    mapParent[cookie.name] = cookie.properties as AnyObject?
                }
                cookieDict[domain] = mapParent
            }

            userDefaults.set(cookieDict, forKey: "cookiesKey")
        }

        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
              if navigationAction.targetFrame == nil {
                  webView.load(navigationAction.request)
              }
              if navigationAction.targetFrame == nil {
                  let newPopupView = createPopupPrivacyView(configuration: configuration)
                  return newPopupView
              }
              
              return nil
          }
        
        func createPopupPrivacyView(configuration: WKWebViewConfiguration) -> WKWebView {
            let popWV = WKWebView(frame: .zero, configuration: configuration)
            popWV.navigationDelegate = self
            popWV.uiDelegate = self
            popWV.allowsBackForwardNavigationGestures = true
            popWV.scrollView.isScrollEnabled = true

            par.webView.addSubview(popWV)
            popWV.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                popWV.topAnchor.constraint(equalTo: par.webView.topAnchor),
                popWV.bottomAnchor.constraint(equalTo: par.webView.bottomAnchor),
                popWV.leadingAnchor.constraint(equalTo: par.webView.leadingAnchor),
                popWV.trailingAnchor.constraint(equalTo: par.webView.trailingAnchor)
            ])
            self.par.gameMenUtil.gamesViews.append(popWV)
            return popWV
        }
        
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let wkPrefs = WKPreferences()
        wkPrefs.javaScriptCanOpenWindowsAutomatically = true
        wkPrefs.javaScriptEnabled = true
        
        let wPaDePref = WKWebpagePreferences()
        wPaDePref.allowsContentJavaScript = true
        
        let conf = WKWebViewConfiguration()
        conf.allowsInlineMediaPlayback = true
        conf.requiresUserActionForMediaPlayback = false
        conf.preferences = wkPrefs
        conf.defaultWebpagePreferences = wPaDePref

        webView = WKWebView(frame: .zero, configuration: conf)
        setGameUtilsOptions(context: context, webView: webView)
        
        return webView
    }

    private func setGameUtilsOptions(context: Context, webView: WKWebView) {
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.isScrollEnabled = true
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.uiDelegate = context.coordinator

        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            let dataStore = webView.configuration.websiteDataStore
            cookies.forEach { cookie in
                dataStore.httpCookieStore.setCookie(cookie)
            }
        }
        
        gameDatUp()
    }
    
    private func gameDatUp() {
        let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
                
        let cookstor = HTTPCookieStorage.shared
        let defusr = UserDefaults.standard

        if let cooksadda: [String: [String: [HTTPCookiePropertyKey: AnyObject]]]? = (defusr.dictionary(forKey: "cookiesKey") ?? [:]) as [String: [String: [HTTPCookiePropertyKey: AnyObject]]] {
            for (_, cookieMap) in cooksadda ?? [:] {
                for (_, cookie) in cookieMap {
                    if let cookie: [HTTPCookiePropertyKey: AnyObject]? = cookie as [HTTPCookiePropertyKey: AnyObject] {
                        if cookie != nil {
                            let cookieValue = HTTPCookie(properties: cookie!)
                            cookstor.setCookie(cookieValue!)
                            cookieStore.setCookie(cookieValue!)
                        }
                    }
                }
            }
        }
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: u)
        uiView.load(request)
    }

    func goBack() {
       if gameMenUtil.gamesViews.count > 0 {
            gameMenUtil.gamesViews.forEach { $0.removeFromSuperview() }
            gameMenUtil.gamesViews.removeAll()
            webView.load(URLRequest(url: u))
        } else {
            if webView.canGoBack {
                webView.goBack()
            }
        }
    }

    func refresh() {
       webView.reload()
    }
}


#Preview {
    GamesMenu()
}
