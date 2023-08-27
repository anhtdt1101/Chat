//
//  ChatLogViewModel.swift
//  Chat
//
//  Created by Tien Anh Tran Duc on 27/08/2023.
//

import Foundation
import FirebaseFirestore



class ChatLogViewModel: ObservableObject {
    @Published var count = 0
    @Published var chatText = ""
    @Published var errorMessage = ""
    @Published var chatMessage: [ChatMessage] = []
    
    var chatUser: ChatUser?
    var firestoreListener: ListenerRegistration?

    init(chatUser: ChatUser?){
        self.chatUser = chatUser
        fetchMessages()
    }
    
    func fetchMessages(){
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = chatUser?.uid else {return}
        firestoreListener?.remove()
        chatMessage.removeAll()
        firestoreListener = FirebaseManager.shared.firestore.collection("messages")
            .document(fromId)
            .collection(toId)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen for messages: \(error)"
                    print(error)
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        do {
                            if let data = try? change.document.data(as: ChatMessage.self) {
                                self.chatMessage.append(data)
                            }
                        } catch {
                            print(error)
                        }
                    }
                })
                
                DispatchQueue.main.async {
                    self.count += 1
                }
            }
        
    }
    
    func handleSend(){
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = chatUser?.uid else {return}
        
        let document = FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .document()
        let messageData = [FirebaseConstants.fromId: fromId,
                           FirebaseConstants.toId: toId,
                           FirebaseConstants.text: self.chatText,
                           "timestamp": Timestamp()] as [String: Any]
        
        document.setData(messageData) { error in
            if let error = error {
                print(error)
                self.errorMessage = "Failed to save message into FireStore: \(error)"
                return
            }
            
            self.persistRecentMessage()
            self.chatText = ""
            self.count += 1
        }
        
        let recipientMessageDocument = FirebaseManager.shared.firestore
            .collection("messages")
            .document(toId)
            .collection(fromId)
            .document()
        
        recipientMessageDocument.setData(messageData) { error in
            if let error = error {
                print(error)
                self.errorMessage = "Failed to save message into FireStore: \(error)"
                return
            }
        }
    }
    
    private func persistRecentMessage(){
        guard let chatUser = chatUser else { return }
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = self.chatUser?.uid else { return }
        
        let document = FirebaseManager.shared.firestore
            .collection("recent_messages")
            .document(uid)
            .collection("messages")
            .document()
        
        let data = [FirebaseConstants.timestamp: Timestamp(),
                    FirebaseConstants.text: self.chatText,
                    FirebaseConstants.fromId: uid,
                    FirebaseConstants.toId: toId,
                    FirebaseConstants.profileImageUrl: chatUser.profileImageUrl,
                    FirebaseConstants.email: chatUser.email] as [String: Any]
        
        document.setData(data) { error in
            if let error = error{
                self.errorMessage = "Failed to save recent message: \(error)"
                print("Failed to save recent message: \(error)")
                return
            }
        }
        
    }
    
}
