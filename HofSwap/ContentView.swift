//
//  ContentView.swift
//  HofSwap
//
//  Created by Trey Jean on 4/2/20.
//  Copyright © 2020 Trey Jean. All rights reserved.
//

import SwiftUI
import Firebase

struct ContentView: View {
    @EnvironmentObject var session: SessionStore
    func getUser() {
        session.listen()
    }
 
    var body: some View {
        Group {
            if session.session == nil {
                SignInView()
            } else {
                TabView {
                    ProfileView(userName: "\(self.session.userFName + "" + self.session.userLName)")
                        .tabItem {
                            VStack {
                                Image(systemName: "house.fill")
                                Text("Home")
                                    .font(.system(size: 16, weight: .light))
                            }
                        }
                    SearchView()
                        .tabItem {
                            VStack {
                                Image(systemName: "magnifyingglass")
                                Text("Search")
                                    .font(.system(size: 16, weight: .light))
                            }
                    }
                }
            }
        }.onAppear(perform: getUser)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct SearchView: View {
    @State var searchQ = ""
    @EnvironmentObject var session: SessionStore
    
    func search() {
        self.session.search(search: self.searchQ)
        self.searchQ = ""
    }
    
    var body: some View {
        VStack {
            HStack {
                TextField("Name, ISBN, Author", text: $searchQ)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: search) {
                    Text("Search")
                    Image(systemName: "magnifyingglass")
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .foregroundColor(.white)
                .background(Color.accentColor)
                .cornerRadius(10)
            }.padding(.vertical, 8)
            ScrollView {
                VStack {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 16) {
                            ForEach(0..<self.session.searchedTextbooks.count) { x in
                                HStack {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .frame(minWidth: 0, maxWidth: 200)
                                    VStack(alignment: .leading) {
                                        Text("\(self.session.searchedTextbooks[x].name ?? "")")
                                            .font(.system(size: 20, weight: .medium))
                                        Text("\(self.session.searchedTextbooks[x].edition ?? "") Edition")
                                            .font(.system(size: 16, weight: .medium))
                                        Spacer().frame(height: 32)
                                        Text("\(self.session.searchedTextbooks[x].author ?? "")")
                                            .font(.system(size: 16, weight: .medium))
                                        }.padding(8)
                                        .frame(minWidth: 150, maxWidth: 200, minHeight: 200, maxHeight: 350)
                                        .foregroundColor(.white)
                                        .background(Color.accentColor)
                                }
                            }
                            .cornerRadius(5)
                            Spacer()
                        }
                    }
                }
            }
            Spacer()
            
        }.padding(.horizontal,16)
            .onAppear(perform: search)
    }
}

