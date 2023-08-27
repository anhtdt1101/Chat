//
//  ChatLogView.swift
//  Chat
//
//  Created by Tien Anh Tran Duc on 26/08/2023.
//

import SwiftUI
import FirebaseFirestore

struct ChatLogView: View {

    @ObservedObject var vm: ChatLogViewModel
    
    var body: some View {
        ZStack{
            messageView
            Text(vm.errorMessage)
            
        }
        .navigationTitle(vm.chatUser?.email ?? "---")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear{
            vm.firestoreListener?.remove()
        }
    }
    
    private var chatBottomBar: some View {
        HStack{
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 24))
                .foregroundColor(Color(.darkGray))
            TextField("Description", text: $vm.chatText)
            Button {
                vm.handleSend()
            } label: {
                Text("Send")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.blue)
            .cornerRadius(4)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        
    }
    
    static let emptyScrollToString = "Empty"
    
    private var messageView: some View {
        VStack{
            if #available(iOS 15.0, *) {
                ScrollView{
                    ScrollViewReader { scrollViewProxy in
                        VStack{
                            ForEach(vm.chatMessage) { message in
                                MessageView(message: message)
                            }
                            HStack{ Spacer() }
                                .id(Self.emptyScrollToString)
                        }
                        .onReceive(vm.$count) { _ in
                            withAnimation(.easeOut(duration: 0.5)) {
                                scrollViewProxy.scrollTo(Self.emptyScrollToString,anchor: .bottom)
                            }
                            
                        }
                    }
                }
                .background(Color(.init(white: 0.95, alpha: 1)))
                .safeAreaInset(edge: .bottom) {
                    chatBottomBar
                        .background(Color(.systemBackground).ignoresSafeArea())
                }
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
}

struct MessageView: View {
    let message: ChatMessage
    
    var body: some View{
        VStack{
            if message.fromId == FirebaseManager.shared.auth.currentUser?.uid {
                HStack{
                    Spacer()
                    HStack{
                        Text(message.text)
                            .foregroundColor(.white)
                    }.padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            } else {
                HStack{
                    HStack{
                        Text(message.text)
                            .foregroundColor(.black)
                    }.padding()
                        .background(Color.white)
                        .cornerRadius(8)
                    Spacer()
                }
            }
        } .padding(.horizontal)
            .padding(.top, 8)
    }
}

//struct ChatLogView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            ChatLogView(chatUser: .init(["email": "fake@gmail.com", "uid": "34KtGVnl1VdMYC7FLB1Qbwl4E2m1"]))
//        }
//    }
//}
