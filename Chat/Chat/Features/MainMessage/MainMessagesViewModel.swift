//
//  MainMessagesViewModel.swift
//  Chat
//
//  Created by Tien Anh Tran Duc on 27/08/2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class MainMessagesViewModel: ObservableObject{
    
    @Published var chatUser: ChatUser?
    @Published var recentMessage = [RecentMessage]()
    @Published var isUserCurrentlyLoggedOut = false
    
    private var firestoreListener: ListenerRegistration?
    
    init() {
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        fetchCurrentUser()
        fetchRecentMessages()
    }
    
    func fetchRecentMessages(){
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        firestoreListener?.remove()
        self.recentMessage.removeAll()
        
        firestoreListener = FirebaseManager.shared.firestore
            .collection("recent_messages")
            .document(uid)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, err in
                if let err = err {
                    print("Failed to listen for recent messages:", err)
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    let docId = change.document.documentID
                    if let index = self.recentMessage.firstIndex(where: {$0.id == docId}){
                        self.recentMessage.remove(at: index)
                    }
                    do {
                        if let rm = try? change.document.data(as: RecentMessage.self) {
                            self.recentMessage.insert(rm, at: 0)
                        }
                    } catch {
                        print(err)
                    }
                })
                
            }
        
    }
    
    func fetchCurrentUser(){
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snapshot, err in
            if let err = err {
                print("Failed to fetch current user:", err)
                return
            }
            guard let data = snapshot?.data() else { return }
            self.chatUser = .init(data: data)
        }
    }
    
    func handleSignOut(){
        isUserCurrentlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
    }
    
}
