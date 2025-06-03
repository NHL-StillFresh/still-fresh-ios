//
//  SetupView.swift
//  Still Fresh
//
//  Created by Jesse van der Voet on 20/05/2025.
//

import SwiftUI

struct SetupView : View {
    @ObservedObject var userState: UserStateModel
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var callbackMessage: String = ""
    
    var body: some View {
        ZStack {
            Color("LoginBackgroundColor").ignoresSafeArea()
            VStack(spacing: 24) {
                Image("LoginImage")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(height: UIScreen.main.bounds.height * 0.32)
                    .clipped()
                    .padding(.top, 32)
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("Let's get to know you!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    Text("Enter your first and last name to personalize your experience.")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.horizontal, 24)
                
                VStack(spacing: 12) {
                    TextField("", text: $firstName)
                        .placeholder(when: firstName.isEmpty) {
                            Text("First name").foregroundColor(.white.opacity(0.6))
                        }
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .autocapitalization(.words)
                        .disableAutocorrection(true)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.15))
                        )
                    TextField("", text: $lastName)
                        .placeholder(when: lastName.isEmpty) {
                            Text("Last name").foregroundColor(.white.opacity(0.6))
                        }
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .autocapitalization(.words)
                        .disableAutocorrection(true)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.15))
                        )
                }
                .padding(.horizontal, 24)
                
                if !callbackMessage.isEmpty {
                    Text(callbackMessage)
                        .foregroundColor(.red)
                        .padding(.horizontal, 24)
                }
                
                Button(action: {
                    if firstName.isEmpty || lastName.isEmpty {
                        callbackMessage = "Please fill in both fields."
                        return
                    }
                    Task {
                        defer {
                            userState.isLoading = false
                        }
                        
                        userState.isLoading = true
                        do {
                            if userState.userProfile == nil {
                                fatalError("User profile not set.")
                            }
                            
                            debugPrint("SetupView: ", userState.userProfile!.UID)
                            
                            let insertedProfile: ProfileModel = try await SupaClient
                                .from("profiles")
                                .insert(ProfileModel(
                                    user_id: String(describing: userState.userProfile!.UID),
                                    profile_first_name: firstName,
                                    profile_last_name: lastName,
                                    created_at: nil,
                                    updated_at: nil))
                                .select()
                                .single()
                                .execute()
                                .value
                            
                            userState.userProfile?.firstName = insertedProfile.profile_first_name
                            userState.userProfile?.lastName = insertedProfile.profile_last_name
                            userState.isSetup = true
                        } catch {
                            debugPrint(error.localizedDescription)
                        }
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
                .padding(.horizontal, 24)
                .padding(.top, 8)
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}
