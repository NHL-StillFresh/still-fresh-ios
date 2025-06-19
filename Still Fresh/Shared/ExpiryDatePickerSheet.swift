import SwiftUI

struct ExpiryDatePickerSheet: View {
    @Binding var isPresented: Bool
    let foodItem: FoodItem
    let onDateUpdated: (Date) -> Void
    
    @State private var selectedDate: Date
    @State private var isUpdating = false
    
    init(isPresented: Binding<Bool>, foodItem: FoodItem, onDateUpdated: @escaping (Date) -> Void) {
        self._isPresented = isPresented
        self.foodItem = foodItem
        self.onDateUpdated = onDateUpdated
        self._selectedDate = State(initialValue: foodItem.expiryDate)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    // Food item info
                    HStack(spacing: 12) {
                        if let imageUrl = foodItem.image {
                            AsyncImage(url: URL(string: imageUrl)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(red: 122/255, green: 190/255, blue: 203/255).opacity(0.2))
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: "fork.knife")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color(red: 122/255, green: 190/255, blue: 203/255))
                                }
                            }
                            .frame(width: 50, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(red: 122/255, green: 190/255, blue: 203/255).opacity(0.2))
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: "fork.knife")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(red: 122/255, green: 190/255, blue: 203/255))
                            }
                            .frame(width: 50, height: 50)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(foodItem.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text("Current expiry: \(formattedDate(foodItem.expiryDate))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    Divider()
                }
                
                VStack(spacing: 16) {
                    Text("Select New Expiry Date")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    DatePicker(
                        "Expiry Date",
                        selection: $selectedDate,
                        in: Date()..., // Only allow dates from today onwards
                        displayedComponents: .date
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                }
                
                Spacer()
                
                Button(action: updateExpiryDate) {
                    HStack(spacing: 8) {
                        if isUpdating {
                            ProgressView()
                                .scaleEffect(0.8)
                                .tint(.white)
                        } else {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .medium))
                        }
                        
                        Text(isUpdating ? "Updating..." : "Update Expiry Date")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.04, green: 0.29, blue: 0.29))
                    )
                    .shadow(color: Color(red: 0.04, green: 0.29, blue: 0.29).opacity(0.3), radius: 6, x: 0, y: 2)
                }
                .disabled(isUpdating || selectedDate == foodItem.expiryDate)
                .opacity(isUpdating || selectedDate == foodItem.expiryDate ? 0.6 : 1.0)
            }
            .padding(24)
            .navigationTitle("Change Expiry Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .disabled(isUpdating)
                }
            }
        }
        .interactiveDismissDisabled(isUpdating)
    }
    
    private func updateExpiryDate() {
        isUpdating = true
        onDateUpdated(selectedDate)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    ExpiryDatePickerSheet(
        isPresented: .constant(true),
        foodItem: FoodItem(
            name: "Organic Milk",
            store: "Albert Heijn",
            image: nil,
            expiryDate: Date()
        ),
        onDateUpdated: { _ in }
    )
} 