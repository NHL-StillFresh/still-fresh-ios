//
//  LoginWithEmailView.swift
//  Still Fresh
//
//  Created by Gideon Dijkhuis on 07/05/2025.
//
import SwiftUI

struct LoginWithEmailView: View {
    @State private var userHasAccount: Bool = false
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var passwordConfirm: String = ""
    @State private var goToStartView = false
    @Environment(\.dismiss) private var dismiss
    
    private var emailToLogin: String = "app@stillfresh.nl"
    private var passwordToLogin: String = "123456"
    
    var body: some View {
        ZStack {
            Color("LoginBackgroundColor").ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header with close button
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                            )
                    }
                }
                .padding(.top, 8)
                
                // Form content
                VStack(alignment: .leading, spacing: 24) {
                    if email == "" || !userHasAccount{
                        fillInEmail()
                    }
                    else if userHasAccount {
                        fillInPassword()
                    }
                    else {
                        createAccount()
                    }
                    
                    // Continue button
                    Button(action: {
                        if email == "" {
                            return
                        }
                        
                        if userHasAccount && password == passwordToLogin {
                            goToStartView = true
                            return
                        }
                        
                        if email.lowercased() == emailToLogin {
                            userHasAccount = true
                            return
                        }
                        
                        userHasAccount = false
                    }) {
                        HStack {
                            Spacer()
                            Text("Continue")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .frame(height: 56)
                        .background(Color.white)
                        .foregroundColor(Color("LoginBackgroundColor"))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                    .padding(.top, 16)
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                
                Spacer()
            }
            .padding()
        }
        .fullScreenCover(isPresented: $goToStartView) {
            StartView()
        }
    }
    
    func fillInEmail() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("What's your email?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text("We'll check if you have an account with us")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            VStack(spacing: 8) {
                TextField("", text: $email)
                    .placeholder(when: email.isEmpty) {
                        Text("Email address").foregroundColor(.white.opacity(0.6))
                    }
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .disableAutocorrection(true)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.15))
                    )
            }
        }
    }

    func fillInPassword() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Fill in your password")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Welcome back, \(email)!")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            VStack(spacing: 8) {
                SecureField("", text: $password)
                    .placeholder(when: password.isEmpty) {
                        Text("Password").foregroundColor(.white.opacity(0.6))
                    }
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.15))
                    )
            }
        }
    }

    func createAccount() -> some View{
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Create your account")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Please note, this isn't supported yet, because it's in Test Mode")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            VStack(spacing: 12) {
                SecureField("", text: $password)
                    .placeholder(when: password.isEmpty) {
                        Text("Password").foregroundColor(.white.opacity(0.6))
                    }
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.15))
                    )
                
                SecureField("", text: $passwordConfirm)
                    .placeholder(when: passwordConfirm.isEmpty) {
                        Text("Confirm password").foregroundColor(.white.opacity(0.6))
                    }
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.15))
                    )
            }
        }
    }
}

// Custom extension for placeholder text
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    LoginWithEmailView()
}
