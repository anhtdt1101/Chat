//
//  LoginView.swift
//  Chat
//
//  Created by Tien Anh Tran Duc on 11/08/2023.
//

import SwiftUI
import Firebase
import FirebaseStorage

class FirebaseManager: NSObject{
    let auth: Auth
    let storage: Storage
    let firestore: Firestore
    
    static let shared = FirebaseManager()
    
    override init() {
        FirebaseApp.configure()
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
        super.init()
    }
    
}

struct LoginView: View {
    @State var isLoginMode = false
    @State var email = ""
    @State var password = ""
    @State var shouldShowImagePicker = false
    
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
                                    Image(systemName: "person.fill").font(.system(size: 64)).foregroundColor(.black)
                                        .padding()
                                }
                            }.overlay(RoundedRectangle(cornerRadius: 64).stroke(Color.black, lineWidth: 3))
                        }
                    }
                    
                    Group{
                        TextField("Email", text: $email).keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        SecureField("Password", text: $password)
                    } .padding(12).background(Color.white)
                    
                    Button {
                        handleAction()
                    } label: {
                        HStack{
                            Spacer()
                            Text(isLoginMode ? "Log In" : "Create Account").foregroundColor(.white).padding()
                                .font(.system(size: 16, weight: .semibold))
                            Spacer()
                        }.background(Color.blue)
                    }
                    
                }.padding()
                
                Text(self.loginStatusMessage).foregroundColor(Color.red).padding()
                
            }.navigationTitle( isLoginMode ? "Log In" : "Create Account")
                .background(Color(.init(white: 0, alpha: 0.05)).ignoresSafeArea())
        }.navigationViewStyle(StackNavigationViewStyle())
            .fullScreenCover(isPresented: $shouldShowImagePicker) {
                ImagePicker(image: $image)
            }
    }
    
    @State var loginStatusMessage = ""
    @State var image: UIImage?
    
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
        }
    }
    
    private func createNewAccount(){
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
        let userData = ["email": self.email,
                        "uid": uid,
                        "profileImageUrl": imageProfileUrl.absoluteString]
        
        FirebaseManager.shared.firestore.collection("users").addDocument(data: userData) { err in
            if let err = err {
                print(err)
                self.loginStatusMessage = "\(err)"
                return
            }
            print("Success")
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
