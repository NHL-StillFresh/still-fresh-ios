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
    @State private var navigationState: NavigationState = .login
    @State private var username = "User"

    var color = Color("LoginBackgroundColor")
    var buttonHeight:CGFloat = 50;
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Color(color)
            VStack() {
                Image("LoginImage").scaledToFill()
                Text("Your groceries called-").colorInvert().font(.title).fontWeight(.semibold)
                Text("they want to stay fresh").colorInvert().font(.title).fontWeight(.semibold)
                SignInWithAppleButton(.signUp) {
                    request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: {
                    result in
                    switch result {
                    case .success(let authorization):
                        handleSuccessfulLogin(with: authorization)
                    case .failure(let error):
                        handleLoginError(with: error)
                    }
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
                    LoginWithEmailView(onLoginSuccess: { email in
                        // Extract username from email for welcome message
                        if let atIndex = email.firstIndex(of: "@") {
                            username = String(email[..<atIndex])
                        }
                        navigationState = .welcome
                    })
                    .presentationDetents([.medium])
                }

            }.padding()
        }.background(color)
        .fullScreenCover(isPresented: .init(
            get: { navigationState == .welcome },
            set: { if !$0 { navigationState = .start } }
        )) {
            WelcomeAnimation(username: username, isPresented: .init(
                get: { navigationState == .welcome },
                set: { if !$0 { navigationState = .start } }
            ))
        }
        .fullScreenCover(isPresented: .init(
            get: { navigationState == .start },
            set: { _ in }
        )) {
            StartView()
        }
    }
    
    private func handleSuccessfulLogin(with authorization: ASAuthorization) {
        if let userCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // Extract name for welcome message
            if userCredential.authorizedScopes.contains(.fullName) && userCredential.fullName?.givenName != nil {
                username = userCredential.fullName?.givenName ?? "User"
            }
                    
            if userCredential.authorizedScopes.contains(.email) {
                print(userCredential.email ?? "No email")
                // If no name is available, try to extract from email
                if username == "User" && userCredential.email != nil {
                    if let email = userCredential.email, let atIndex = email.firstIndex(of: "@") {
                        username = String(email[..<atIndex])
                    }
                }
            }
            
            navigationState = .welcome
        }
    }
        
    private func handleLoginError(with error: Error) {
        print("Could not authenticate: \(error.localizedDescription)")
    }
    
    // Define navigation states
    enum NavigationState {
        case login
        case welcome
        case start
    }
}

#Preview {
    LoginView()
}
