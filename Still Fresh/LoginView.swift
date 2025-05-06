//
//  Login.swift
//  Still Fresh
//
//  Created by Gideon Dijkhuis on 06/05/2025.
//

import SwiftUI
import AuthenticationServices

struct LoginView : View {
    var color = Color("LoginBackgroundColor")
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Color(color)
            VStack() {
                Text("Your groceries called-")
                Text("They want to stay fresh")
                SignInWithAppleButton(.signUp) {
                    request in
                } onCompletion: {
                    result in
                }.frame(height: 50)
                
            }.padding()
        }.background(color)

    }
}

#Preview {
    LoginView()
}
