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
    var buttonHeight:CGFloat = 50;
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Color(color)
            VStack() {
                Image("LoginImage").scaledToFill()
                Text("Your groceries called-").colorInvert().font(.title)
                Text("they want to stay fresh").colorInvert().font(.title)
                SignInWithAppleButton(.signUp) {
                    request in
                } onCompletion: {
                    result in
                }.frame(height: buttonHeight)
                Text("or").colorInvert()
                Button(action: {
                    
                }) {
                    HStack {
                        Spacer()
                        Text("Continue with email")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .frame(height: 50)
                    .background(Color.white)
                    .foregroundColor(Color("LoginBackgroundColor"))
                    .cornerRadius(8)
                }

            }.padding()
        }.background(color)

    }
}

#Preview {
    LoginView()
}
