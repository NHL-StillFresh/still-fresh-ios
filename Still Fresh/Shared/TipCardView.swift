import SwiftUI

struct TipCardView: View {
    let tip: FoodSavingTip
    
    var body: some View {
        ZStack(alignment: .center) {
            // Card background
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 122/255, green: 190/255, blue: 203/255))
            
            // Background image with clipping
            Image("tip-bg")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity)
                .offset(y: -20) // Move the image up by 20 points
                .clipped() // Add clipping to prevent overflow
            
            // Content overlay
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                
                // Main tip text - moved to bottom
                Text(tip.content)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                
                // Bottom tags
                HStack {
                    // Tips tag
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 11))
                        
                        Text("Tips")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 10)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                    )
                    
                    Spacer()
                    
                    // Fridge tag
                    HStack(spacing: 4) {
                        Text("Fridge")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                    )
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .frame(width: UIScreen.main.bounds.width * 0.75, height: 140)
        .clipShape(RoundedRectangle(cornerRadius: 16)) // Clip the entire card to ensure nothing overflows
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    TipCardView(tip: FoodSavingTip(content: "Store cheese in wax paper, not plastic."))
        .padding()
} 
