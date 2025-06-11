import SwiftUI

struct RecipeCardView: View {
    let recipe: Recipe
    
    // Background color for recipes 
    private var bgColor: Color {
        Color(red: 122/255, green: 190/255, blue: 203/255).opacity(0.2)
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Card background
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
            
            // Content container with no spacing at top
            VStack(alignment: .leading, spacing: 0) {
                // Recipe image
                ZStack(alignment: .topLeading) {
                    // Recipe illustration with background
                    ZStack {
                        Rectangle()
                            .fill(bgColor)
                        
                        Image(systemName: "fork.knife")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(24)
                            .foregroundColor(bgColor.opacity(1.5))
                    }
                    .frame(height: 110)
                    .frame(maxWidth: .infinity)
                    
                    // Time tag in top left
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 10))
                        Text(recipe.cookingTimeText)
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.6))
                    )
                    .padding(12)
                }
                
                // Recipe details with spacing from image
                VStack(alignment: .leading, spacing: 8) {
                    Text(recipe.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    // Description
                    Text(recipe.description)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .padding(.bottom, 4)
                    
                    // Tags
                    HStack {
                        // Difficulty tag
                        HStack(spacing: 4) {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(recipe.difficulty.color)
                                .font(.system(size: 12))
                            
                            Text(recipe.difficulty.rawValue)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(recipe.difficulty.color)
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(
                            Capsule()
                                .fill(recipe.difficulty.color.opacity(0.1))
                        )
                        
                        Spacer()
                        
                        // Main tag
                        if let firstTag = recipe.tags.first {
                            Text(firstTag)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(
                                    Capsule()
                                        .fill(Color.gray.opacity(0.1))
                                )
                        }
                    }
                    
                    // Button to view recipe
                    Button(action: {
                        // TODO: Navigate to recipe details
                    }) {
                        Text("View Recipe")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color(red: 122/255, green: 190/255, blue: 203/255))
                            .cornerRadius(10)
                    }
                    .padding(.top, 6)
                }
                .padding(.top, 8)
                .padding(.horizontal, 14)
                .padding(.bottom, 12)
            }
        }
        .frame(width: UIScreen.main.bounds.width * 0.6, height: 250)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    ScrollView(.horizontal) {
        HStack(spacing: 16) {
            RecipeCardView(recipe: Recipe.sampleRecipes[0])
            RecipeCardView(recipe: Recipe.sampleRecipes[1])
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
} 