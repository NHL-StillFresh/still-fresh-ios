//
//  LoginWithEmailView.swift
//  Still Fresh
//
//  Created by Gideon Dijkhuis on 07/05/2025.
//
import SwiftUI
import Supabase
import Foundation

enum AppState {
    case email
    case login
    case register
}

struct LoginWithEmailView: View {
    @ObservedObject var userState: UserStateModel
    @State private var loginState: AppState = .email
    @State private var isTaskDone: Bool = false
    @State private var optForCreation: Bool = false
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var passwordConfirm: String = ""
    @State private var callbackMessage: String = ""
    @Environment(\.dismiss) private var dismiss
    
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
                    switch loginState {
                    case .email:
                        FillInEmailView()
                    case .login:
                        FillInPasswordView()
                    case .register:
                        CreateNewAccountView()
                    @unknown default:
                        FillInEmailView()
                    }
                    Text(callbackMessage)
                        .foregroundColor(.red)
                    
                    // Continue button
                    Button(action: {
                        callbackMessage = ""
                        
                        if loginState == .email {
                            if email.isEmpty || !isValidEmail(email) {
                                callbackMessage = "Please provide a valid email address."
                                loginState = .email
                                return
                            } else {
                                loginState = .login
                            }
                        } else if loginState == .login {
                            if password.isEmpty {
                                callbackMessage = "Please provide a password."
                                loginState = .login
                                return
                            }
                            authenticateUser()
                            return
                        } else if loginState == .register {
                            createUser()
                        }
                        
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
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                
                Spacer()
            }
            .padding()
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func authenticateUser() {
        Task {
            do {
                try await SupaClient
                    .auth
                    .signIn(email: email, password: password)
                
                userState.isAuthenticated = true
            } catch {
                callbackMessage = error.localizedDescription.debugDescription
                optForCreation = true
                
            }
        }
    }
    
    func createUser() {
        Task {
            do {
                if !isValidEmail(email) {
                    callbackMessage = "Please enter a valid email address"
                    return
                }
                
                if password != passwordConfirm {
                    callbackMessage = "Passwords do not match"
                    return
                }
                
                let authResult = try await SupaClient
                    .auth
                    .signUp(email: email, password: password)
                
                debugPrint("Created user auth: \(authResult)")
                
                userState.isAuthenticated = true
                userState.userProfile = ProfileObject(UID: String(describing: authResult.user.id))
            } catch {
                callbackMessage = error.localizedDescription.description
            }
        }
    }
    
    func FillInEmailView() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("What's your email?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Enter your email address below to log in or create an account.")
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

    func FillInPasswordView() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Fill in your password")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Enter your password for this email-")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                Text("account: \(email)")
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
                if optForCreation {
                    Button(action: {
                        password = ""
                        loginState = .register
                    }) {
                        HStack {
                            Spacer()
                            Text("Create new account")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .frame(height: 50)
                        .background(Color.white)
                        .foregroundColor(Color("LoginBackgroundColor"))
                        .cornerRadius(8)
                    }
                }
            }
        }
    }

    func CreateNewAccountView() -> some View{
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Create your account")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Start saving groceries with us!")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                Text("You will be creating an account")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                Text("with this email: \(email).")
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
    LoginView(userState: UserStateModel())
}
