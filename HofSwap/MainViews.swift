//
//  MainViews.swift
//  HofSwap
//
//  Created by Trey Jean on 4/8/20.
//  Copyright © 2020 Trey Jean. All rights reserved.
//

import SwiftUI
import Firebase

struct ProfileView: View {
    @State var showMenu = false
    @State var showProfileMenu = false
    @State var showSettingsMenu = false
    
    var userName: String
    @State var flag: Bool = true
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .trailing) {
                MainProfileView(showMenu: self.$showMenu).zIndex(0)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .disabled(self.showMenu ? true : false)
                    .disabled(self.showProfileMenu ? true : false)
                    .opacity(self.showMenu || self.showSettingsMenu || self.showProfileMenu ? 0.1 : 1)
                
                if self.showMenu {
                    MenuView(showMenu: self.$showMenu, showProfileMenu: self.$showProfileMenu, showSettingsMenu: self.$showSettingsMenu).zIndex(1)
                        .frame(width: geometry.size.width/1.5, height: geometry.size.height)
                        .offset(x: self.showMenu ? geometry.size.width/8 : 0)
                        .animation(.easeOut(duration: 1.0))
                        .disabled(self.showMenu ? false : true)
                        .transition(.move(edge: .trailing))
                }
                
                if self.showProfileMenu {
                    ProfileMenu(showMenu: self.$showMenu, showProfileMenu: self.$showProfileMenu).zIndex(5)
                        .frame(width: geometry.size.width/1.1, height: geometry.size.height)
                        .offset(x: self.showProfileMenu ? 0-geometry.size.width/8 : 0)
                        .animation(.easeOut(duration: 1.0))
                        .disabled(self.showProfileMenu ? false : true)
                        .transition(.move(edge: .leading))
                }
                
                if self.showSettingsMenu {
                    SettingsMenu(showMenu: self.$showMenu, showSettingsMenu: self.$showSettingsMenu).zIndex(5)
                        .frame(width: geometry.size.width/1.1, height: geometry.size.height)
                        .offset(x: self.showSettingsMenu ? 0-geometry.size.width/8 : 0)
                        .animation(.easeOut(duration: 1.0))
                        .disabled(self.showSettingsMenu ? false : true)
                        .transition(.move(edge: .leading))
                }
                
            }.onAppear(perform: {self.flag.toggle()})
        }
    }
}

struct MainProfileView: View {
    @EnvironmentObject var session: SessionStore
    var ref: DocumentReference? = nil
    
    @Binding var showMenu: Bool
    @State var flag = false
    
    // Upload Form
    @State private var textbookName: String = ""
    @State private var textbookEdition: String = ""
    @State private var textbookAuthor: String = ""
    @State private var textbookISBN: String = ""
    @State private var textbookPrice: String = ""
    
    var body: some View {
        VStack { // Main Profile View
            HStack { // Header
                HStack {
                    Image(systemName: "person.circle")
                        .resizable()
                        .frame(minWidth: 0, maxWidth: 40, minHeight: 0, maxHeight: 40)
                    VStack(alignment: .leading) {
                        Text("\(self.session.userFName + " " + self.session.userLName)")
                            .font(.system(size: 16, weight: .medium))
                        Button(action: {
                            withAnimation {
                                self.showMenu = true
                            }
                        }) {
                            Text("Options")
                                .font(.system(size: 12, weight: .light))
                                .foregroundColor(.accentColor)
                        }
                    }
                    Spacer()
                }
                
            }.padding(.vertical, 8)
            Divider()
            HStack { // Your Textbooks
                Text("Your Textbooks")
                    .font(.system(size: 24, weight: .medium))
            }
            if self.session.textbooks.count == 0 {
                HStack(alignment: .center) {
                    Text("Upload a Textbook")
                        .font(.system(size: 20, weight: .light))
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(0..<self.session.textbooks.count) { x in
                            HStack {
                                Image(systemName: "photo").resizable()
                                    .frame(width: 300, height: 450)
                            }
                        }
                        .cornerRadius(5)
                        Spacer()
                    }
                }.padding(.bottom, 16)
            }
            Divider()
            VStack { // Upload View
                Text("Upload Textbook View")
                    .font(.system(size: 24, weight: .medium))
                VStack(spacing: 12) {
                    TextField("Textbook name", text: self.$textbookName)
                    TextField("Edition", text: self.$textbookEdition).keyboardType(.numberPad)
                    TextField("Author", text: self.$textbookAuthor)
                    HStack(spacing: 12) {
                        TextField("ISBN", text: self.$textbookISBN)
                        TextField("Price", text: self.$textbookPrice)
                    }
                }.textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.bottom, 16)
                Button(action: {_ = """
                    Firestore.firestore().collection("textbooks").addDocument(data: [
                        "user": self.session.session!.uid,
                        "name": self.textbookName,
                        "edition": self.textbookEdition,
                        "author": self.textbookAuthor
                    ])
                    self.textbookName = ""
                    self.textbookAuthor = ""
                    self.textbookEdition = ""
                    self.flag.toggle()
                    self.session.listen()
                """}) {
                    Text("Submit")
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, idealHeight: 50, maxHeight: 50)
                    .foregroundColor(.white)
                    .background(Color.accentColor)
                    .cornerRadius(10)
                
            }.padding(.bottom, 16)
            Spacer()
        }.padding(.horizontal, 16)
            .onAppear(perform: {
                self.session.listen()
                self.flag.toggle()
            })
    }
}

struct MenuView: View {
    @Binding var showMenu: Bool
    @Binding var showProfileMenu: Bool
    @Binding var showSettingsMenu: Bool
    
    @EnvironmentObject var session: SessionStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Button(action: {
                self.showMenu = false
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Back")
                        .font(.system(size: 16, weight: .medium))
                }
            }
            .foregroundColor(.white)
            .padding(.top, 16)
            
            Button(action: {
                self.showProfileMenu = true
                self.showMenu = false
            }) {
                Image(systemName: "person")
                Text("Profile")
                    .font(.system(size: 16, weight: .medium))
            }.foregroundColor(.white)
            .padding(.top, 16)
            
            Button(action: {}) {
                Image(systemName: "envelope")
                Text("Messages")
                    .font(.system(size: 16, weight: .medium))
            }.foregroundColor(.white)
                .disabled(true)
                .opacity(0.3)
            
            Button(action: {
                self.showSettingsMenu = true
                self.showMenu = false
            }) {
                Image(systemName: "gear")
                Text("Settings")
                    .font(.system(size: 16, weight: .medium))
            }.foregroundColor(.white)
            
            Spacer()
            Button(action: {self.session.signOut()}) {
                Image(systemName: "square.and.arrow.up.on.square")
                Text("Sign Out")
                    .font(.system(size: 16, weight: .medium))
            }.foregroundColor(.white)
                .padding(.bottom, 16)
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color.accentColor)
        .edgesIgnoringSafeArea(.horizontal)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

struct ProfileMenu: View {
    @Binding var showMenu: Bool
    @Binding var showProfileMenu: Bool
    
    @State private var email: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Text("Edit Your Profile")
                    .font(.system(size: 16, weight: .medium))
                Spacer()
                Button(action: {
                    self.showProfileMenu = false
                    self.showMenu = true
                }) {
                    HStack {
                        Image(systemName: "chevron.right")
                        Text("Back")
                            .font(.system(size: 16, weight: .medium))
                    }
                }
            }
            .foregroundColor(.white)
            .padding(.vertical, 16)
            
            Spacer()
            
        }
        .padding(.leading, 16)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
        .background(Color.accentColor)
        .edgesIgnoringSafeArea(.horizontal)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

struct SettingsMenu: View {
    @Binding var showMenu: Bool
    @Binding var showSettingsMenu: Bool
    var body: some View {
        VStack {
            HStack {
                Text("Settings")
                    .font(.system(size: 16, weight: .medium))
                Spacer()
                Button(action: {
                    self.showSettingsMenu = false
                    self.showMenu = true
                }) {
                    HStack {
                        Image(systemName: "chevron.right")
                        Text("Back")
                            .font(.system(size: 16, weight: .medium))
                    }
                }
            }
            .foregroundColor(.white)
            .padding(.top, 16)
            
            Spacer()
        }
        .padding(.leading, 16)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
        .background(Color.accentColor)
        .edgesIgnoringSafeArea(.horizontal)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}



struct MainViews_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(userName: "Trey Jean")
    }
}
