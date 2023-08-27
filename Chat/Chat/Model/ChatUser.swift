//
//  ChatUser.swift
//  Chat
//
//  Created by Tien Anh Tran Duc on 26/08/2023.
//

import Foundation

struct ChatUser: Identifiable {
    var id: String { uid }
    
    var email, uid, profileImageUrl: String
    
    init(data: [String: Any]) {
        self.email = data[FirebaseConstants.email] as? String ?? ""
        self.uid = data[FirebaseConstants.uid] as? String ?? ""
        self.profileImageUrl = data[FirebaseConstants.profileImageUrl] as? String ?? ""
    }
}
