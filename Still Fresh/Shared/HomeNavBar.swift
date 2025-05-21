import SwiftUI

struct HomeNavBar: View {
    @ObservedObject var userState = UserStateModel()
    
    @State private var greeting: String = ""
    @State private var showAccountScreen = false
    @State private var timeIcon: String = "sun.max"
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Image(systemName: timeIcon)
                            .foregroundColor(Color(UIColor.systemTeal))
                            .font(.system(size: 17, weight: .medium))
                            .symbolRenderingMode(.palette)
                            .offset(y: -2)
                        
                        Text(greeting)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color(UIColor.darkText))
                    }
                    
                    Text(userState.userProfile?.firstName ?? "John")
                        .font(.system(size: 24))
                        .fontWeight(.bold)
                        .foregroundColor(Color(UIColor.darkText))
                }
            }
            
            Spacer()
            
            Button(action: {
                showAccountScreen = true
            }) {
                Image(systemName: "gearshape")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(.black)
                    .symbolRenderingMode(.palette)
            }
            .sheet(isPresented: $showAccountScreen) {
                SettingsView()
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
            case 0..<5:
            greeting = "Good Night"
            timeIcon = "moon"
            case 5..<12:
            greeting = "Good Morning"
            timeIcon = "sunrise"
            case 12..<17:
                greeting = "Good Afternoon"
                timeIcon = "sun.max"
            default:
                greeting = "Good Evening"
                timeIcon = "moon.stars"
        }
    }
}

#Preview {
    HomeNavBar()
} 
