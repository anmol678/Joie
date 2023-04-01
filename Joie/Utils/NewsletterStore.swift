//
//  NewsletterStore.swift
//  Joie
//
//  Created by Anmol Jain on 4/1/23.
//

import Foundation

class NewsletterStore: ObservableObject {
    @Published var newsletters: [Newsletter] = []
    
    let query = "label:snipd"
    
    func fetchNewsletters(completion: @escaping () -> Void) {
        fetchNewslettersFromGmail(with: query, completion: { newsletters in
            // Update your newsletterStore with the fetched newsletters
            DispatchQueue.main.async {
                self.newsletters = newsletters
                completion()
            }
        })
    }
}
