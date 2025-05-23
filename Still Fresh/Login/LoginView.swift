//
//  Login.swift
//  Still Fresh
//
//  Created by Gideon Dijkhuis on 06/05/2025.
//

import SwiftUI
import AuthenticationServices

struct LoginView : View {
    // Used to keep track of user state
    @ObservedObject var userState: UserStateModel
    @State private var showingLoginSheet = false

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
                    Task {
                        defer {
                            userState.isLoading = false
                        }
                        userState.isLoading = true
                        
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
                            let authResult = try await SupaClient.auth.signInWithIdToken(
                                credentials: .init(
                                    provider: .apple,
                                    idToken: idToken
                                )
                            )
                        
                            await userState.setNewUserProfile(profileObject: ProfileObject(UID: String(describing:authResult.user.id)))
                            
                            userState.isAuthenticated = true
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
                    LoginWithEmailView(userState: userState)
                    .presentationDetents([.medium])
                }

            }.padding()
        }.background(color)
    }
}

#Preview {
    LoginView(userState: UserStateModel())
}
