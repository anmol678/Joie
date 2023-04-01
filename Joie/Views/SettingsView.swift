//
//  SettingsView.swift
//  Joie
//
//  Created by Anmol Jain on 3/31/23.
//

import SwiftUI
import GoogleSignIn

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var newsletterStore: NewsletterStore
    @State private var email: String = ""

    var body: some View {
        NavigationView {
            VStack {
                Text("Sign in with Google")
                    .font(.headline)
                    .padding(.bottom, 20)

                Button(action: {
                    signInWithGoogle()
                }) {
                    GIDSignInButtonWrapper()
                }
                .frame(width: 200, height: 50)
            }
            .padding()
            .navigationBarTitle("Settings", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }

    private func signInWithGoogle() {
        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
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
                
                // User is signed in, update the email address in the view
                email = profile.email

                
                // Call your fetchNewsletters function here, for example:
                newsletterStore.fetchNewsletters {
                    DispatchQueue.main.async {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}


struct GIDSignInButtonWrapper: UIViewRepresentable {
    func makeUIView(context: Context) -> GIDSignInButton {
        return GIDSignInButton()
    }

    func updateUIView(_ uiView: GIDSignInButton, context: Context) {
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

