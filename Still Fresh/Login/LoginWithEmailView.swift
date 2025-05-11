//
//  LoginWithEmailView.swift
//  Still Fresh
//
//  Created by Gideon Dijkhuis on 07/05/2025.
//
import SwiftUI
import Supabase
import Foundation

struct LoginWithEmailView: View {
    @State private var userHasAccount: Bool = false
    @State private var userHasValidEmail: Bool = false
    @State private var isTaskDone: Bool = false
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var passwordConfirm: String = ""
    @State private var callbackMessage: String = ""
    @State private var goToStartView = false
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
                    if userHasValidEmail && isTaskDone {
                        if !userHasAccount {
                            createAccount()
                        } else {
                            fillInPassword()
                        }
                    }
                    else {
                        fillInEmail()
                    }
                    
                    Text(callbackMessage)
                        .foregroundColor(.red)
                    
                    // Continue button
                    Button(action: {
                        callbackMessage = ""
                        if email.isEmpty {
                            callbackMessage = "Please provide an email address."
                            return
                        }
                        
                        userHasValidEmail = isValidEmail(email)
                        
                        if !userHasValidEmail {
                            callbackMessage = "Please provide a valid email address."
                            
                            return
                        }
                        
                        if userHasAccount {
                            callbackMessage = "Logging you in right now..."
                            authenticateUser()
                            return
                        } else if !password.isEmpty{
                            createUser()
                        } else {
                            hasExistingAccount()
                        }
                        
                        return
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
        .fullScreenCover(isPresented: $goToStartView) {
            StartView()
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    struct UserModel: Decodable {
        let user_email: String
    }
    
    func hasExistingAccount() {
        Task {
            do {
                isTaskDone = false
                
                defer {
                    isTaskDone = true
                }
                
                let users: [UserModel] = try await SupaClient
                    .from("users")
                    .select("user_email")
                    .eq("user_email", value: email)
                    .execute()
                    .value
                
                userHasAccount = users.count > 0
            } catch {
                callbackMessage = error.localizedDescription
            }
        }
    }
    
    func authenticateUser() {
        Task {
            do {
                try await SupaClient
                    .auth
                    .signIn(email: email, password: password)
                
                goToStartView = true
            } catch {
                callbackMessage = error.localizedDescription
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
                
                try await SupaClient
                    .auth
                    .signUp(email: email, password: password)
                
                callbackMessage = "Please check your inbox for a verification email and login to continue"
            } catch {
                callbackMessage = error.localizedDescription
            }
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
                
                Text("Please note, this isn't fully supported yet, any account created must be deleted via de webpanel in Supabase")
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
