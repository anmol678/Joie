//
//  ContentView.swift
//  Joie
//
//  Created by Anmol Jain on 3/31/23.
//

import SwiftUI

struct ContentView: View {
    @State private var isSettingsPresented = false

    var body: some View {
        NavigationView {
            NewsletterView()
                .navigationBarItems(trailing: Button(action: {
                    isSettingsPresented.toggle()
                }) {
                    Image(systemName: "gearshape")
                })
                .sheet(isPresented: $isSettingsPresented) {
                    SettingsView()
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(NewsletterStore())
    }
}
