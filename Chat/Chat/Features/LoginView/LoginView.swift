//
//  LoginView.swift
//  Chat
//
//  Created by Tien Anh Tran Duc on 11/08/2023.
//

import SwiftUI

struct LoginView: View {
    
    let didCompleteLoginProcess: () -> ()
    
    @State private var isLoginMode = false
    @State private var email = ""
    @State private var password = ""
    @State private var shouldShowImagePicker = false
    
    @State private var loginStatusMessage = ""
    @State private var image: UIImage?
    
    var body: some View {
        NavigationView{
            ScrollView{
                VStack(spacing: 16){
                    Picker(selection: $isLoginMode, label: Text("Picker here")) {
                        Text("Login").tag(true)
                        Text("Create account").tag(false)
                    }.pickerStyle(SegmentedPickerStyle())
                    if !isLoginMode{
                        Button {
                            shouldShowImagePicker.toggle()
                        } label: {
                            VStack {
                                if let image = image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 128, height: 128)
                                        .cornerRadius(64)
                                    
                                } else {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 64))
                                        .foregroundColor(Color(.label))
                                        .padding()
                                }
                            }.overlay(RoundedRectangle(cornerRadius: 64).stroke(Color(.label), lineWidth: 3))
                        }
                    }
                    
                    Group{
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        SecureField("Password", text: $password)
                    }
                    .padding(12)
                    .background(Color.white)
                    
                    Button {
                        handleAction()
                    } label: {
                        Spacer()
                            Text(isLoginMode ? "Log In" : "Create Account")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .semibold))
                        Spacer()
                    }.padding()
                    .background(Color(.blue))
                    .cornerRadius(8)
                    
                }.padding()
                
                Text(self.loginStatusMessage).foregroundColor(Color.red).padding()
                
            }.navigationTitle( isLoginMode ? "Log In" : "Create Account")
                .background(Color(.init(white: 0, alpha: 0.05)).ignoresSafeArea())
        }.navigationViewStyle(StackNavigationViewStyle())
            .fullScreenCover(isPresented: $shouldShowImagePicker) {
                ImagePicker(image: $image)
            }
    }

    private func handleAction(){
        if isLoginMode{
            loginUser()
        } else {
            createNewAccount()
        }
    }
    
    private func loginUser(){
        FirebaseManager.shared.auth.signIn(withEmail: self.email, password: self.password) { result, err in
            if let err = err {
                print("Failed to login:", err)
                self.loginStatusMessage = "Failed to login: \(err)"
                return
            }
            print("Successfully logged user: \(result?.user.uid ?? "")")
            self.loginStatusMessage = "Successfully logged user: \(result?.user.uid ?? "")"
            
            self.didCompleteLoginProcess()
        }
    }
    
    private func createNewAccount(){
        if self.image == nil {
            self.loginStatusMessage = "You must select an avatar image"
            return
        }
        
        FirebaseManager.shared.auth.createUser(withEmail: self.email, password: self.password) { result, err in
            if let err = err {
                print("Failed to create:", err)
                self.loginStatusMessage = "Failed to create: \(err)"
                return
            }
            print("Successfully created user: \(result?.user.uid ?? "")")
            self.loginStatusMessage = "Successfully created user: \(result?.user.uid ?? "")"
            persistImageToStorage()
        }
    }
    
    private func persistImageToStorage(){
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else { return }
        ref.putData(imageData, metadata: nil) { metadata, err in
            if let err = err {
                self.loginStatusMessage = "Failed to push image to Storage: \(err)"
                return
            }
            
            ref.downloadURL { url, err in
                if let err = err {
                    self.loginStatusMessage = "Failed to retrieve download Url: \(err)"
                    return
                }
                
                self.loginStatusMessage = "Successfully stored image with url: \(url?.absoluteString ?? "")"
                guard let url = url else { return }
                self.storeUserInformation(imageProfileUrl: url)
            }
        }
    }
    
    private func storeUserInformation(imageProfileUrl: URL) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let userData = [FirebaseConstants.email: self.email,
                        FirebaseConstants.uid: uid,
                        FirebaseConstants.profileImageUrl: imageProfileUrl.absoluteString]
        
        FirebaseManager.shared.firestore.collection("users").document(uid).setData(userData) { err in
            if let err = err {
                print(err)
                self.loginStatusMessage = "\(err)"
                return
            }
            print("Success")
            self.didCompleteLoginProcess()
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView {
            
        }
    }
}
