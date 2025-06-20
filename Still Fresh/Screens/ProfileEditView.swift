import SwiftUI
import Auth
import Supabase

struct ProfileEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var userState: UserStateModel
    
    @State private var isFirstNameEmpty: Bool = false

    @State private var editedFirstName: String
    @State private var editedLastName: String
    
    private let tealColor = Color(red: 122/255, green: 190/255, blue: 203/255)
    
    init(userState: UserStateModel) {
        self.userState = userState
        self._editedFirstName = State(initialValue: userState.userProfile?.firstName ?? "")
        self._editedLastName = State(initialValue: userState.userProfile?.lastName ?? "")
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Profile photo
                ZStack {
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(tealColor)
                    
                    // Camera button for photo change (UI only)
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            AsyncImage(url: userState.userProfile?.image) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle().stroke(Color.teal, lineWidth: 2)
                                        )
                                } placeholder: {
                                    ProgressView()
                                        .frame(width: 40, height: 40)
                                }
                        }
                    }
                    .frame(width: 100, height: 100)
                    .offset(x: 5, y: 5)
                }
                .padding(.top, 20)
                
                // Form fields
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("First Name")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        TextField("Your first name", text: $editedFirstName)
                            .font(.system(size: 16))
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(isFirstNameEmpty ? Color.red : Color.clear, lineWidth: 2)
                            )
                            .onChange(of: editedFirstName) {
                                isFirstNameEmpty = false
                            }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Last Name")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        TextField("Your last name", text: $editedLastName)
                            .font(.system(size: 16))
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Save button
                Button(action: {
                    Task {
                        do {
                            
                            if editedFirstName == "" {
                                print("First name is empty")
                                isFirstNameEmpty = true
                                return
                            }
                            isFirstNameEmpty = false
                            // Update the profile in the database
                            let updatedProfile: ProfileModel = try await SupaClient
                                .from("profiles")
                                .update([
                                    "profile_first_name": editedFirstName,
                                    "profile_last_name": editedLastName
                                ])
                                .eq("user_id", value: userState.userProfile?.UID ?? "")
                                .select()
                                .single()
                                .execute()
                                .value
                            
                            let newProfile: ProfileObject = ProfileObject(UID: updatedProfile.user_id, firstName: updatedProfile.profile_first_name, lastName: updatedProfile.profile_last_name)
                            
                            userState.userProfile = newProfile
                            
                            presentationMode.wrappedValue.dismiss()
                        } catch {
                            print("Failed to update profile: \(error)")
                        }
                    }
                }) {
                    Text("Save Changes")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(tealColor)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                            .font(.system(size: 16, weight: .medium))
                    }
                }
            }
        }
    }
}

#Preview {
    let userState = UserStateModel()
    userState.userProfile = ProfileObject(UID: "test-id", firstName: "John", lastName: "Doe")
    return ProfileEditView(userState: userState)
} 
