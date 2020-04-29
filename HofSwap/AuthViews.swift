//
//  AuthView.swift
//  HofSwap
//
//  Created by Trey Jean on 4/2/20.
//  Copyright © 2020 Trey Jean. All rights reserved.
//

import SwiftUI
import Firebase

struct SignInView: View {
    @State private var id: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    
    @State private var error: String = ""
    
    @EnvironmentObject var session: SessionStore
    
    func signIn() {
        session.signIn(email: email, password: password) { (result, error) in
            if let error = error {
                self.error = error.localizedDescription
            } else {
                self.email = ""
                self.password = ""
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome Back!")
                    .font(.system(size: 32, weight: .heavy))
                Text("Please Sign In to Continue")
                    .font(.system(size: 16, weight: .light))
                
                VStack(spacing: 16) {
                    TextField("Hofstra ID", text: $id)
                        .font(.system(size: 16, weight: .medium))
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 5).strokeBorder(Color.primary, lineWidth: 1))
                    
                    TextField("Email", text: $email).keyboardType(.emailAddress)
                        .font(.system(size: 16, weight: .medium))
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 5).strokeBorder(Color.primary, lineWidth: 1))
                    
                    SecureField("Password", text: $password)
                        .font(.system(size: 16, weight: .medium))
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 5).strokeBorder(Color.primary, lineWidth: 1))
                }.padding(.vertical, 32)
                
                
                Button(action: signIn) {
                    Text("Sign In")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 50)
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .medium))
                        .background(LinearGradient(gradient: Gradient(colors: [.primary, .accentColor]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(5)
                }
                
                if self.error != "" {
                    Text(self.error)
                        .font(.system(size: 12, weight: .light))
                        .foregroundColor(.red)
                        .padding(.vertical,16)
                }
                
                NavigationLink(destination: SignUpView()) {
                    HStack {
                        Text("Already Have and Account?")
                            .font(.system(size: 14, weight: .light))
                            .foregroundColor(.primary)
                        Text("Create and Account")
                            .font(.system(size: 14, weight: .light))
                            .foregroundColor(.accentColor)
                    }.padding(.vertical,16)
                    
                }
                Spacer()
            } // VStack
            .padding(.horizontal, 32)
        } // Nav View
    } // Body
}

struct SignUpView: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    
    @State private var error: String = ""
    
    @EnvironmentObject var session: SessionStore
    
    func signUp() {
        session.signUp(email: email, password: password) { (result, error) in
            if let error = error {
                self.error = error.localizedDescription
            } else {
                self.email = ""
                self.password = ""
                
                self.session.listen()
                
                if self.session.session != nil {
                    Firestore.firestore().collection("users").document(self.session.session!.uid).setData([
                        "first_name": self.firstName,
                        "last_name": self.lastName
                    ])
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            VStack {
                Text("Create an Account")
                    .font(.system(size: 32, weight: .heavy))
                Text("Sign Up to Get Started")
                    .font(.system(size: 16, weight: .light))
            }
            
            VStack(spacing: 16) {
                HStack(spacing: 8) {
                    TextField("First Name", text: $firstName)
                        .font(.system(size: 16, weight: .medium))
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 5).strokeBorder(Color.primary, lineWidth: 1))
                    TextField("Last Name", text: $lastName)
                        .font(.system(size: 16, weight: .medium))
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 5).strokeBorder(Color.primary, lineWidth: 1))
                }
                TextField("Email", text: $email)
                    .font(.system(size: 16, weight: .medium))
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 5).strokeBorder(Color.primary, lineWidth: 1))
                SecureField("Password", text: $password)
                    .font(.system(size: 16, weight: .medium))
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 5).strokeBorder(Color.primary, lineWidth: 1))
            }.padding(.vertical, 32)
            
            Button(action: signUp) {
                Text("Sign Up")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(.white)
                    .font(.system(size: 24, weight: .medium))
                    .background(LinearGradient(gradient: Gradient(colors: [.primary, .accentColor]), startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(5)
            }
            
            if self.error != "" {
                Text(self.error)
                    .font(.system(size: 12, weight: .light))
                    .foregroundColor(.red)
                    .padding(.vertical,16)
            }
            Spacer()
        } // VStack
            .padding(.horizontal, 32)
    } // Body
}


struct AuthViews_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
