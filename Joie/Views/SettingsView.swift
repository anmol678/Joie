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
    
    @State var newQuery: String = ""

    var body: some View {
        NavigationView {
            VStack {
                if let profile = newsletterStore.userProfile {
                    Form {
                        Section(header: Text("User Profile")) {
                            HStack {
                                if let imageURL = profile.imageURL(withDimension: 100) {
                                    RemoteImage(url: imageURL)
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .leading) {
                                    Text(profile.name)
                                    Text(profile.email)
                                }
                            }
                            .padding()
                        }
                        
                        Section(header: Text("Queries")) {
                            ForEach(newsletterStore.queries.indices, id: \.self) { index in
                                TextField("Query", text: $newsletterStore.queries[index])
                            }
                            .onDelete(perform: newsletterStore.deleteQuery)
                            
                            HStack {
                                TextField("Add query", text: $newQuery)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                Button(action: {
                                    newsletterStore.addQuery(newQuery)
                                    newQuery = ""
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                }
                            }
                        }
                        
                        Section(header: Text("Fetch")) {
                            Button(action: {
                                newsletterStore.fetchNewsletters {
                                    DispatchQueue.main.async {
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }
                            }) {
                                Text("Fetch Data")
                            }
                        }
                    }
                } else {
                    SignInButton()
                }
            }
//            .padding()
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

