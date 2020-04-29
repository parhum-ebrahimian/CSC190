//
//  SessionStore.swift
//  HofSwap
//
//  Created by Trey Jean on 4/3/20.
//  Copyright © 2020 Trey Jean. All rights reserved.
//

import Foundation
import Firebase
import Combine

class SessionStore: ObservableObject {
    var didChange = PassthroughSubject<SessionStore,Never>()
    @Published var session: User? {didSet {self.didChange.send(self)}}
    @Published var userFName: String = "" {didSet {self.didChange.send(self)}}
    @Published var userLName: String = "" {didSet {self.didChange.send(self)}}
    
    @Published var textbooks: [Textbook] = [] {didSet {self.didChange.send(self)}}
    @Published var numYourTextbooks = 0 {didSet {self.didChange.send(self)}}
    @Published var searchedTextbooks: [Textbook] = [] {didSet {self.didChange.send(self)}}
    @Published var numTextbooks = 0 {didSet {self.didChange.send(self)}}
    var handle: AuthStateDidChangeListenerHandle?
    
    func search(search: String) {
        let db = Firestore.firestore().collection("textbooks").whereField("name", isEqualTo: search).whereField("author", isEqualTo: search)
        db.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(err.localizedDescription)
            } else {
                for document in querySnapshot!.documents {
                    let book = Textbook(uid: document.documentID, name: document.get("name") as? String, edition: document.get("edition") as? String, author: document.get("author") as? String)
                    if self.searchedTextbooks.contains(book) == false {
                        self.searchedTextbooks.append(book)
                    }
                }
            }
        }
        self.numTextbooks = searchedTextbooks.count
    }
    
    func listen() {
        handle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if let user = user {
                self.session = User(uid: user.uid, email: user.email)
                
                let docRef = Firestore.firestore().collection("users").document("\(user.uid)")

                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        self.userFName = document.get("first_name") as! String
                        self.userLName = document.get("last_name") as! String
                    } else {
                        print("Document does not exist")
                    }
                }
                
                Firestore.firestore().collection("textbooks").whereField("user", isEqualTo: user.uid).addSnapshotListener { (snap, err) in
                    if err != nil {
                        print((err?.localizedDescription)!)
                        return
                    }
                    var temp: [Textbook] = []
                    for i in snap!.documentChanges {
                        let id = i.document.documentID
                        let name = i.document.get("name") as! String
                        let edition = i.document.get("edition") as! String
                        let author = i.document.get("author") as! String

                        let book = Textbook(uid: id, name: name, edition: edition, author: author)
                        temp.append(book)
                    }
                    self.textbooks = temp
                    self.numYourTextbooks = temp.count
                }
                
                let db = Firestore.firestore().collection("textbooks")
                self.searchedTextbooks = []
                db.getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print(err.localizedDescription)
                    } else {
                        for document in querySnapshot!.documents {
                            let book = Textbook(uid: document.documentID, name: document.get("name") as? String, edition: document.get("edition") as? String, author: document.get("author") as? String)
                            if self.searchedTextbooks.contains(book) == false {
                                self.searchedTextbooks.append(book)
                            }
                        }
                    }
                }
                
            } else {
                self.session = nil
            }
        })
    }
    
    func signUp(email: String, password: String, handler: @escaping AuthDataResultCallback) {
        Auth.auth().createUser(withEmail: email, password: password, completion: handler)
    }
    
    func signIn(email: String, password: String, handler: @escaping AuthDataResultCallback) {
        Auth.auth().signIn(withEmail: email, password: password, completion: handler)
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.session = nil
        } catch {
            print("Error Signing Out")
        }
    }
    
    func unbind() {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    deinit {
        unbind()
    }
}

struct User {
    var uid: String
    var email: String?
    
    init(uid: String, email: String?) {
        self.uid = uid
        self.email = email
    }
}

struct Textbook: Hashable {
    var uid: String
    var name: String?
    var edition: String?
    var author: String?
    
    init(uid: String, name: String?, edition: String?, author: String?) {
        self.uid = uid
        self.name = name
        self.edition = edition
        self.author = author
    }
}
