//
//  NewsletterView.swift
//  Joie
//
//  Created by Anmol Jain on 3/31/23.
//

import SwiftUI

struct Newsletter: Identifiable {
    var id: String
    var title: String
    var description: String
    var sender: String
    var date: Date
    var isRead: Bool
//    var image: Image
}

struct NewsletterRow: View {
    var newsletter: Newsletter

    var body: some View {
        HStack {
//            newsletter.image
//                .resizable()
//                .frame(width: 50, height: 50)
            VStack(alignment: .leading) {
                Text(newsletter.title)
                    .font(.headline)
                Text(newsletter.description)
                    .font(.subheadline)
                    .lineLimit(2)
                    .foregroundColor(.gray)
                Text(newsletter.sender)
                    .font(.caption)
                Text("Received: \(newsletter.date)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            if newsletter.isRead {
                Image(systemName: "checkmark")
            }
        }
    }
}

struct NewsletterView: View {
    @EnvironmentObject var newsletterStore: NewsletterStore

    var body: some View {
        List(newsletterStore.newsletters) { newsletter in
            NewsletterRow(newsletter: newsletter)
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Newsletters")
    }
}


struct NewsletterView_Previews: PreviewProvider {
    static var previews: some View {
        NewsletterView()
    }
}
