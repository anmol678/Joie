//
//  JoieApp.swift
//  Joie
//
//  Created by Anmol Jain on 3/31/23.
//

import SwiftUI
import GoogleSignIn

@main
struct JoieApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var newsletterStore = NewsletterStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(newsletterStore)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize Google Sign-In
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: "561230275373-ik6t2om0t2ij6j1kg7jju76g29mhavo4.apps.googleusercontent.com")
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}
