//
//  Login.swift
//  Still Fresh
//
//  Created by Gideon Dijkhuis on 06/05/2025.
//

import SwiftUI
import AuthenticationServices

struct LoginView : View {
    @State private var showingLoginSheet = false

    var color = Color("LoginBackgroundColor")
    var buttonHeight:CGFloat = 50;
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Color(color)
            VStack() {
                Image("LoginImage").scaledToFill()
                Text("Your groceries called-").colorInvert().font(.title).fontWeight(.semibold)
                Text("they want toa stay fresh").colorInvert().font(.title).fontWeight(.semibold)
                SignInWithAppleButton(.signUp) {
                    request in
                } onCompletion: {
                    result in
                }.frame(height: buttonHeight)
                Text("or").colorInvert()
                Button(action: {
                    showingLoginSheet = true
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
                }.sheet(isPresented: $showingLoginSheet) {
                    LoginWithEmailView()                 .presentationDetents([.medium])
                }

            }.padding()
        }.background(color)

    }
}

#Preview {
    LoginView()
}
