//
//  LoginWithEmailView.swift
//  Still Fresh
//
//  Created by Gideon Dijkhuis on 07/05/2025.
//
import SwiftUI

struct LoginWithEmailView: View {

    var body: some View {
        VStack() {
            Text("Log in with email").font(.headline)
            TextField("Email", text: .constant("")).textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Password", text: .constant("")).textFieldStyle(RoundedBorderTextFieldStyle())
            Button(action: {}) {
                Text("Login")
            }
        }.padding()
    }
}

#Preview {
    LoginWithEmailView()
}
