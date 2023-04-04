//
//  SignInButton.swift
//  Joie
//
//  Created by Anmol Jain on 4/3/23.
//

import SwiftUI
import GoogleSignIn

struct SignInButton: View {
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var newsletterStore: NewsletterStore
    
    var body: some View {
        VStack {
            Text("Sign in with Google")
                .font(.headline)
                .padding(.bottom, 8)

            Button(action: {
                newsletterStore.signInWithGoogle {
                    newsletterStore.fetchNewsletters {
                        DispatchQueue.main.async {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }) {
                GIDSignInButtonWrapper()
            }
            .frame(width: 200, height: 50)
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
