//
//  Still_FreshApp.swift
//  Still Fresh
//
//  Created by Gideon Dijkhuis on 26/04/2025.
//

import SwiftUI
import UIKit

// Keep this in the `Still_FreshApp.swift` file
// Used to keep track of user bound state
class UserStateModel : ObservableObject {
    @Published var isAuthenticated: Bool = false
    // Put this in this model because why not
    @Published var userProfile: ProfileObject? = nil
    // Set to true by default because of another warning I am not bothered to fix...
    @Published var isLoading: Bool = true
    @Published var isSetup: Bool = false
    
    init() {
        Task {
            // Makes sure that whatever happens the loading screen gets killed after leaving the scope
            defer {
                Task {
                    await MainActor.run {
                        self.isLoading = false
                    }
                }
            }

            do {
                debugPrint(NSStringFromClass(UserStateModel.self) + ": Attemping to fetch existing user session...")
                // Query existing sessions if exists...
                let user = try await SupaClient.auth.session.user
                debugPrint(user)
                debugPrint(NSStringFromClass(UserStateModel.self) + ": User was found!")
                
                
                await MainActor.run {
                    debugPrint(NSStringFromClass(UserStateModel.self) + ": Active session was found! Setting isAuthenticated to true...")
                    self.isAuthenticated = true
                }
                
                do {
                    debugPrint(NSStringFromClass(UserStateModel.self) + ": Fetching users data if exists...")
                    let profile: ProfileModel = try await SupaClient
                        .from("profiles")
                        .select()
                        .eq("user_id", value: user.id)
                        .limit(1)
                        .single()
                        .execute()
                        .value
                    
                    await MainActor.run {
                        debugPrint(NSStringFromClass(UserStateModel.self) + ": Found user profile, setting it in userStateModel...")
                        self.userProfile = ProfileObject(
                            UID: profile.user_id,
                            firstName: profile.profile_first_name, lastName: profile.profile_last_name)
                        self.isSetup = true
                    }
                } catch {
                    debugPrint(NSStringFromClass(UserStateModel.self) + ": Could not identify user profile...")
                    await MainActor.run {
                        self.userProfile = ProfileObject(UID: String(describing: user.id))
                    }
                    debugPrint(NSStringFromClass(UserStateModel.self) + ": User ID is set to: " + self.userProfile!.UID)
                }
                
                
            } catch {
                debugPrint(NSStringFromClass(UserStateModel.self) + ": UserStateModel: fetching user session failed with error: " + error.localizedDescription)
                
                await MainActor.run {
                    self.isAuthenticated = false
                    self.userProfile = nil
                    self.isSetup = false
                }
            }
        }
    }
    public func invalidateSession() {
        self.isAuthenticated = false
        self.isSetup = false
        self.userProfile = nil
    }
}

class ProfileObject : ObservableObject {
    // We don't allow this to change for obvious reasons.
    let UID: String
    @Published var firstName: String = "John"
    @Published var lastName: String = "Doe"
    @Published var image: String? = nil
    
    // Used for account creation I guess
    init(UID: String) {
        self.UID = UID
    }
    
    // Used when an account is actually found without image
    init(UID: String, firstName: String, lastName: String) {
        self.UID = UID
        self.firstName = firstName
        self.lastName = lastName
    }
    
    // Used when an account is actually found
    init(UID: String, firstName: String, lastName: String, image: String) {
        self.UID = UID
        self.firstName = firstName
        self.lastName = lastName
        self.image = image
    }
}

@main
struct Still_FreshApp: App {
    @StateObject var userState = UserStateModel()
    
    init() {
        UIView.appearance().overrideUserInterfaceStyle = .light
    }
    
    var body: some Scene {
        WindowGroup {
            // Generic loader, probably don't use for anything other than login...
            if userState.isLoading {
                GenericLoader()
            } else {
                if !userState.isAuthenticated {
                    LoginView(userState: userState)
                        .preferredColorScheme(.light)
                } else if userState.isSetup {
                    StartView(userState: userState)
                        .preferredColorScheme(.light)
                } else {
                    SetupView(userState: userState)
                        .preferredColorScheme(.light)
                }
            }
        }
    }
}
