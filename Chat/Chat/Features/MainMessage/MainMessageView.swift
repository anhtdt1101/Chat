//
//  MainMessageView.swift
//  Chat
//
//  Created by Tien Anh Tran Duc on 14/08/2023.
//

import SwiftUI
import SDWebImageSwiftUI

struct MainMessageView: View {
    @State var chatUser: ChatUser?
    @State var shouldLogoutOptions = false
    @State var shouldNavigateToChatLogView = false
    
    @ObservedObject private var vm = MainMessagesViewModel()
    
    private var chatLogViewModel = ChatLogViewModel(chatUser: nil)
    var body: some View {
        NavigationView{
            VStack() {
                customNavBar
                messageView
                NavigationLink("", isActive: $shouldNavigateToChatLogView) {
                    ChatLogView(vm: chatLogViewModel)
                }
            }
            .overlay(newMessageButton, alignment: .bottom)
            .navigationBarHidden(true)
        }
    }
    
    
    private var customNavBar: some View{
        HStack(spacing: 16){
            WebImage(url: URL(string: vm.chatUser?.profileImageUrl ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipped().cornerRadius(50)
                .overlay(RoundedRectangle(cornerRadius: 44).stroke(Color(.label), lineWidth: 1))
                .shadow(radius: 5)
            
            
            VStack(alignment: .leading,spacing: 4){
                let email = vm.chatUser?.email.components(separatedBy: "@").first ?? "---"
                Text(email)
                    .font(.system(size: 24, weight: .bold))
                HStack{
                    Circle().foregroundColor(.green)
                        .frame(width: 14, height: 14)
                    Text("online").font(.system(size: 12))
                        .foregroundColor(Color(.lightGray))
                }
            }
            Spacer()
            
            Button {
                shouldLogoutOptions.toggle()
            } label: {
                Image(systemName: "gear").font(.system(size: 24, weight: .bold)).foregroundColor(Color(.label))
            }
        }.padding()
            .actionSheet(isPresented: $shouldLogoutOptions) {
                .init(title: Text("Settings"), message: Text("What do you want to do?"),
                      buttons: [.destructive(Text("Sign Out"), action: {
                    print("handle signout")
                    vm.handleSignOut()
                }) , .cancel() ])
            }
            .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut) {
                LoginView {
                    self.vm.isUserCurrentlyLoggedOut = false
                    self.vm.fetchCurrentUser()
                    self.vm.fetchRecentMessages()
                }
            }
    }
    
    private var messageView: some View{
        ScrollView{
            ForEach(vm.recentMessage){ recentMessage in
                VStack{
                    Button {
                        let uid = FirebaseManager.shared.auth.currentUser?.uid == recentMessage.fromId ? recentMessage.toId : recentMessage.fromId
             
                        
                        self.chatUser = ChatUser(data: [FirebaseConstants.email: recentMessage.email,
                                                     FirebaseConstants.profileImageUrl: recentMessage.profileImageUrl,
                                                     FirebaseConstants.uid: uid])
                        
                        self.chatLogViewModel.chatUser = self.chatUser
                        self.chatLogViewModel.fetchMessages()
                        self.shouldNavigateToChatLogView.toggle()
                    } label: {
                        VStack{
                            HStack(spacing: 16){
                                WebImage(url: URL(string: recentMessage.profileImageUrl))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 64,height: 64)
                                    .clipped()
                                    .cornerRadius(64)
                                    .overlay(RoundedRectangle(cornerRadius: 64).stroke(Color(.black), lineWidth: 1))
                                    .shadow(radius: 5)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(recentMessage.userName)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(Color(.label))
                                    Text(recentMessage.text)
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(.lightGray))
                                        .multilineTextAlignment(.leading)
                                }
                                Spacer()
                                
                                Text(recentMessage.timeAge)
                                    .foregroundColor(Color(.label))
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            Divider().padding(.vertical, 8)
                        }.padding(.horizontal)
                        
                    }
                }
            }.padding(.bottom, 50)
                .padding(.top, 10)
        }
    }
    
    @State var shouldShowNewMessageScreen = false
    
    private var newMessageButton: some View{
        Button {
            shouldShowNewMessageScreen.toggle()
        } label: {
            HStack{
                Spacer()
                Text("+ New Message")
                    .font(.system(size: 16,weight: .bold))
                Spacer()
            }.foregroundColor(.white)
                .padding(.vertical)
                .background(Color.blue)
                .cornerRadius(32)
                .padding(.horizontal).shadow(radius: 5)
        }
        .fullScreenCover(isPresented: $shouldShowNewMessageScreen) {
            CreateNewMessageView { user in
                self.shouldNavigateToChatLogView.toggle()
                self.chatUser = user
                self.chatLogViewModel.chatUser = chatUser
                self.chatLogViewModel.fetchMessages()
            }
        }
    }
    
    
    
}


struct MainMessageView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessageView()
    }
}



