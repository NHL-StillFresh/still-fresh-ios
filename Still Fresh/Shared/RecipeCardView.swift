import SwiftUI

struct RecipeCardView: View {
    let recipe: Recipe
    @State private var showFullRecipe: Bool = false
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
                                .foregroundColor(recipe.difficultyColor)
                                .font(.system(size: 12))
                            
                            Text(recipe.difficulty.rawValue)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(recipe.difficultyColor)
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(
                            Capsule()
                                .fill(recipe.difficultyColor.opacity(0.1))
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
                        showFullRecipe = true
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
        .sheet(isPresented: $showFullRecipe) {
            RecipeSheetView(recipe: recipe)
                .presentationDragIndicator(.visible)
        }
    }
}

struct RecipeSheetView: View {
    let recipe: Recipe
    
    private var bgColor: Color {
        Color(red: 122/255, green: 190/255, blue: 203/255).opacity(0.2)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Image
                ZStack {
                    Rectangle()
                        .fill(bgColor)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    Image(systemName: recipe.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(24)
                        .foregroundColor(bgColor.opacity(1.5))
                }
                .frame(height: 110)
                .frame(maxWidth: .infinity)
                
                // Title and Description
                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(recipe.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Tags
                if !recipe.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(recipe.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                
                // Info Row (Time + Difficulty)
                HStack {
                    Label(recipe.cookingTimeText, systemImage: "clock")
                    Spacer()
                    Label(recipe.difficulty.rawValue.capitalized, systemImage: "flame.fill")
                        .foregroundColor(recipe.difficultyColor)
                }
                .font(.subheadline)
                
                // Ingredients
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ingredients")
                        .font(.headline)
                    
                    ForEach(recipe.ingredients, id: \.self) { ingredient in
                        Text("• \(ingredient)")
                    }
                }
                
                // Steps
                VStack(alignment: .leading, spacing: 8) {
                    Text("Steps")
                        .font(.headline)
                    
                    ForEach(recipe.cookingSteps.components(separatedBy: "\n"), id: \.self) { step in
                        Text(step)
                    }
                }
            }
            .padding()
        }
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
