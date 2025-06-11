import SwiftUI

struct ConfirmationPopup: View {
    let title: String
    let message: String
    let confirmText: String
    let confirmAction: () -> Void
    let isDestructive: Bool
    @Binding var isPresented: Bool
    
    init(
        title: String,
        message: String,
        confirmText: String = "Confirm",
        isDestructive: Bool = false,
        isPresented: Binding<Bool>,
        confirmAction: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.confirmText = confirmText
        self.isDestructive = isDestructive
        self._isPresented = isPresented
        self.confirmAction = confirmAction
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text(title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 16) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .buttonStyle(.bordered)
                    
                    Button(confirmText) {
                        confirmAction()
                        isPresented = false
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(isDestructive ? .red : .blue)
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
            )
            .shadow(radius: 8)
            .padding(32)
        }
    }
} 