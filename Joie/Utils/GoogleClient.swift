//
//  GoogleClient.swift
//  Joie
//
//  Created by Anmol Jain on 3/31/23.
//

import Foundation
import GoogleAPIClientForRESTCore
import GoogleAPIClientForREST_Gmail
import GoogleSignIn

func createGmailService(_ currentUser: GIDGoogleUser) -> GTLRGmailService {
    let service = GTLRGmailService()
    service.authorizer = currentUser.fetcherAuthorizer
    return service
}

func fetchNewslettersFromGmail(with query: String, service: GTLRGmailService, _ completion: @escaping ([Newsletter]) -> Void) {
    let listQuery = GTLRGmailQuery_UsersMessagesList.query(withUserId: "me")
    listQuery.q = query
    
    service.executeQuery(listQuery) { (_, response, error) in
        if let error = error {
            print("Error fetching newsletters: \(error.localizedDescription)")
            completion([])
            return
        }
        
        guard
            let response = response as? GTLRGmail_ListMessagesResponse,
            let messages = response.messages
        else {
            completion([])
            return
        }
        
        // Fetch message details for each message
        let messageIds = messages.map { $0.identifier }
        var fetchedNewsletters: [Newsletter] = []
        let dispatchGroup = DispatchGroup()
        let newslettersQueue = DispatchQueue(label: "com.joie.newslettersQueue")
        
        for messageId in messageIds {
            dispatchGroup.enter()
            let messageQuery = GTLRGmailQuery_UsersMessagesGet.query(withUserId: "me", identifier: messageId!)
            messageQuery.format = "full"
            
            service.executeQuery(messageQuery) { (_, messageResponse, messageError) in
                if let messageError = messageError {
                    print("Error fetching message details: \(messageError.localizedDescription)")
                    dispatchGroup.leave()
                    return
                }
                
                guard
                    let message = messageResponse as? GTLRGmail_Message,
                    let headers = message.payload?.headers as? [GTLRGmail_MessagePartHeader]
                else {
                    dispatchGroup.leave()
                    return
                }
                
                // Extract the necessary information from the message
                let messageId = message.identifier ?? ""
                let subject = headers.first(where: { $0.name == "Subject" })?.value ?? ""
                let from = headers.first(where: { $0.name == "From" })?.value ?? ""
                let dateString = headers.first(where: { $0.name == "Date" })?.value ?? ""
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
                let date = dateFormatter.date(from: dateString) ?? Date()
                let snippet = message.snippet ?? ""
                let isRead = !(message.labelIds?.contains("UNREAD") ?? true)
                
                let newsletter = Newsletter(id: messageId, title: subject, description: snippet, sender: from, date: date, isRead: isRead)
               
                newslettersQueue.async {
                    fetchedNewsletters.append(newsletter)
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(fetchedNewsletters)
        }
    }
}
