import SwiftUI

struct ProfileEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var username: String
    @Binding var email: String
    
    @State private var editedUsername: String
    @State private var editedEmail: String
    
    private let tealColor = Color(red: 122/255, green: 190/255, blue: 203/255)
    
    init(username: Binding<String>, email: Binding<String>) {
        self._username = username
        self._email = email
        self._editedUsername = State(initialValue: username.wrappedValue)
        self._editedEmail = State(initialValue: email.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Profile photo
                ZStack {
                    Circle()
                        .fill(tealColor.opacity(0.2))
                        .frame(width: 100, height: 100)
                    
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
                            Image(systemName: "camera.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                                .padding(8)
                                .background(tealColor)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 2)
                                )
                        }
                    }
                    .frame(width: 100, height: 100)
                    .offset(x: 5, y: 5)
                }
                .padding(.top, 20)
                
                // Form fields
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        TextField("Your name", text: $editedUsername)
                            .font(.system(size: 16))
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        TextField("Your email", text: $editedEmail)
                            .font(.system(size: 16))
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Save button
                Button(action: {
                    username = editedUsername
                    email = editedEmail
                    presentationMode.wrappedValue.dismiss()
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
    @State var username = "App Tester"
    @State var email = "apptester@stillfresh.nl"
    
    return ProfileEditView(username: $username, email: $email)
} 