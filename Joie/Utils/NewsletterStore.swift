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
    
    @Published var queries: [String] = ["label:snipd"]
    
    func fetchNewsletters(completion: @escaping () -> Void) {
        if let currentUser = getGoogleUser() {
            let service = createGmailService(currentUser)
            var allNewsletters: [Newsletter] = []
            let dispatchGroup = DispatchGroup()
            let allNewslettersQueue = DispatchQueue(label: "com.joie.allNewslettersQueue")

            for query in queries {
                dispatchGroup.enter()
                fetchNewslettersFromGmail(with: query, service: service) { newsletters in
                    allNewslettersQueue.async {
                        allNewsletters.append(contentsOf: newsletters)
                        dispatchGroup.leave()
                    }
                }
            }

            dispatchGroup.notify(queue: .main) {
                self.newsletters = allNewsletters
                completion()
            }
        }
    }
    
    func addQuery(_ newQuery: String) {
        if !newQuery.isEmpty {
            queries.append(newQuery)
        }
    }
    
    func deleteQuery(at offsets: IndexSet) {
        queries.remove(atOffsets: offsets)
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
