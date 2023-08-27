//
//  CreateNewMessageViewModel.swift
//  Chat
//
//  Created by Tien Anh Tran Duc on 27/08/2023.
//

import Foundation

class CreateNewMessageViewModel: ObservableObject {
    
    @Published var users: [ChatUser] = []
    @Published var errorMessage: String = ""
    
    init() {
        fetchAllUser()
    }
    
    private func fetchAllUser(){
        FirebaseManager.shared.firestore.collection("users").getDocuments { documentSnapshot, err in
            if let err = err {
                print("Failed to fetch users: \(err)")
                self.errorMessage = "Failed to fetch users: \(err)"
                return
            }
            
            documentSnapshot?.documents.forEach({ snapshot in
                let data = snapshot.data()
                
                let user = ChatUser(data: data)
                if user.uid != FirebaseManager.shared.auth.currentUser?.uid {
                    self.users.append(user)
                }
            })
        }
    }
}
