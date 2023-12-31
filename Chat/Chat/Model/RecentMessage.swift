//
//  RecentMessage.swift
//  Chat
//
//  Created by Tien Anh Tran Duc on 27/08/2023.
//

import Foundation
import FirebaseFirestoreSwift

struct RecentMessage: Codable, Identifiable{
    @DocumentID var id: String?
    
    let text, email: String
    let fromId, toId: String
    let profileImageUrl: String
    let timestamp: Date

    var userName: String {
        email.components(separatedBy: "@").first ?? email
    }
    
    var timeAge: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
    
}
