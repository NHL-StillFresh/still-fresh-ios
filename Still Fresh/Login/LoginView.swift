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
    @State private var showStartView = false

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
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: {
                    result in
                    Task {
                      do {
                        guard let credential = try result.get().credential as? ASAuthorizationAppleIDCredential
                        else {
                          return
                        }
                        guard let idToken = credential.identityToken
                          .flatMap({ String(data: $0, encoding: .utf8) })
                        else {
                          return
                        }
                          try await SupaClient.auth.signInWithIdToken(
                          credentials: .init(
                            provider: .apple,
                            idToken: idToken
                          )
                        )
                      } catch {
                        dump(error)
                      }
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
                    LoginWithEmailView()                 .presentationDetents([.medium])
                }

            }.padding()
        }.background(color).fullScreenCover(isPresented: $showStartView) {
            StartView()
        }

    }
    
    private func handleSuccessfulLogin(with authorization: ASAuthorization) {
        if let userCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            if userCredential.authorizedScopes.contains(.fullName) {
                print(userCredential.fullName?.givenName ?? "No given name")
            }
                    
            if userCredential.authorizedScopes.contains(.email) {
                print(userCredential.email ?? "No email")
            }
            
            showStartView = true
        }
    }
        
    private func handleLoginError(with error: Error) {
        print("Could not authenticate: \\(error.localizedDescription)")
    }
}

#Preview {
    LoginView()
}
