//
//  ChatMessage.swift
//  Chat
//
//  Created by Tien Anh Tran Duc on 27/08/2023.
//

import Foundation
import FirebaseFirestoreSwift

struct ChatMessage: Codable, Identifiable {
    @DocumentID var id: String?
    let fromId, toId, text: String
    
}
