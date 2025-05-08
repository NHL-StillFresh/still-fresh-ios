//
//  LoginWithEmailView.swift
//  Still Fresh
//
//  Created by Gideon Dijkhuis on 07/05/2025.
//
import SwiftUI

struct LoginWithEmailView: View {
    @State private var userHasAccount: Bool? = nil
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var passwordConfirm: String = ""
    @State private var goToStartView = false
    
    private var emailToLogin: String = "app@stillfresh.nl"
    private var passwordToLogin: String = "123456"
    
    var body: some View {
        VStack() {
            if email == "" || userHasAccount == nil{
                fillInEmail()
            }
            else if userHasAccount ?? false {
                fillInPassword()
            }
            else {
                createAccount()
            }
            
            Button(action: {
                if email == "" {
                    return
                }
                
                if userHasAccount ?? false && password == passwordToLogin {
                    goToStartView = true
                    return
                }
                
                if email.lowercased() == emailToLogin {
                    userHasAccount = true;
                    return
                }
            }) {
                Text("Continue")
            }
        }.padding().fullScreenCover(isPresented: $goToStartView) {
            StartView()
        }
    }
    
    func fillInEmail() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("What’s your email?").font(.title)
            Text("We will check if you have account with us")
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }

    func fillInPassword() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Fill in your password").font(.title)
            TextField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }

    func createAccount() -> some View{
        VStack(alignment: .leading, spacing: 8) {
            Text("Create your new account").font(.title)
            TextField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Confirm password", text: $passwordConfirm)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}



#Preview {
    LoginWithEmailView()
}
