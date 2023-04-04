//
//  NewsletterStore.swift
//  Joie
//
//  Created by Anmol Jain on 4/1/23.
//

import Foundation
import GoogleSignIn

class NewsletterStore: ObservableObject {
    
    @Published var userProfile: GIDProfileData?
    
    @Published var newsletters: [Newsletter] = []
    
    let query = "label:snipd"
    
    func fetchNewsletters(completion: @escaping () -> Void) {
        if let currentUser = getGoogleUser() {
            fetchNewslettersFromGmail(with: query, service: createGmailService(currentUser), completion: { newsletters in
                // Update your newsletterStore with the fetched newsletters
                DispatchQueue.main.async {
                    self.newsletters = newsletters
                    completion()
                }
            })
        }
    }
    
    func signInWithGoogle(completion: @escaping () -> Void) {
        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
                if let error = error {
                    print("Error signing in: \(error.localizedDescription)")
                    return
                }

                guard
                    let user = result?.user,
                    let profile = user.profile
                else {
                    return
                }
                
                let additionalScopes = [
                    "https://www.googleapis.com/auth/gmail.readonly",
                    "https://www.googleapis.com/auth/gmail.labels"
                ]
                
                user.addScopes(additionalScopes, presenting: rootViewController) { _, error in
                    if let error = error {
                        print("Error adding additional scopes: \(error.localizedDescription)")
                        return
                    }
                }
                
                // User is signed in, update the userProfile
                DispatchQueue.main.async {
                    self?.userProfile = profile
                }
            }
        }
    }
    
    func getGoogleUser() -> GIDGoogleUser? {
        guard let currentUser = GIDSignIn.sharedInstance.currentUser else {
            if GIDSignIn.sharedInstance.hasPreviousSignIn() {
                GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
                    if let error = error {
                        print("Error signing in: \(error.localizedDescription)")
                        return
                    }
                    
                    if let user = user {
                        self?.userProfile = user.profile
                    }
                }
                
                return getGoogleUser()
            }
            
            return nil
        }
        
        DispatchQueue.main.async {
            self.userProfile = currentUser.profile
        }
        
        return currentUser
    }

}
