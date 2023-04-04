//
//  SettingsView.swift
//  Joie
//
//  Created by Anmol Jain on 3/31/23.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var newsletterStore: NewsletterStore

    var body: some View {
        NavigationView {
            VStack {
                if let profile = newsletterStore.userProfile {
                    // Display user profile information
                    HStack {
                        if let imageURL = profile.imageURL(withDimension: 100) {
                            RemoteImage(url: imageURL)
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        }
                        Spacer()
                        VStack {
                            Text("Name: \(profile.name)")
                            Text("Email: \(profile.email)")
                        }
                    }
                    .padding()
                } else {
                    // Display sign-in button
                    SignInButton()
                }
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
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

