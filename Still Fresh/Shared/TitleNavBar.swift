import SwiftUI

struct TitleNavBar: View {
    var title: String
    @ObservedObject var userState: UserStateModel
    @State private var showAccountScreen = false
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 24))
                .fontWeight(.bold)
                .foregroundColor(Color(UIColor.darkText))
            
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
                SettingsView(userState: userState)
            }
        }
        .padding()
    }
}

#Preview {
    TitleNavBar(title: "Inventory", userState: UserStateModel())
}
