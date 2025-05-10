import SwiftUI

struct NavBar: View {
    @State private var greeting: String = ""
    @State private var username: String = "User" // Placeholder until we fetch from DB
    @State private var showAccountScreen = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(greeting)
                    .font(.headline)
                Text(username)
                    .font(.subheadline)
            }
            
            Spacer()
            
            Button(action: {
                showAccountScreen = true
            }) {
                Image(systemName: "person.circle")
                    .font(.system(size: 24))
            }
            .sheet(isPresented: $showAccountScreen) {
                Text("Account Screen") // Placeholder view
                    .presentationDetents([.medium])
            }
        }
        .padding()
        .onAppear {
            updateGreeting()
        }
    }
    
    private func updateGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
            case 0..<12:
                greeting = "Good Morning"
            case 12..<17:
                greeting = "Good Afternoon"
            default:
                greeting = "Good Evening"
        }
    }
}
