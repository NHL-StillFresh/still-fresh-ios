//
//  CheckProductsView.swift
//  Still Fresh
//
//  Created by Gideon Dijkhuis on 15/05/2025.
//

import SwiftUI
import Foundation
import Supabase

enum ProductKnownStatus: CaseIterable {
    case known, unknown, processing
}

struct CheckProductsView: View {
    @State var productLines: [String]
    @State private var productLinesWithStatus: [String: ProductKnownStatus] = [:]
    @State private var showLoading = true
    @State private var searchResults: [String: [JumboProduct]] = [:]
    @State private var selectedProducts: [String: JumboProduct] = [:]
    @State private var expandedProducts: Set<String> = []
    @State private var isAddingProducts = false
    @State private var showWarningAlert = false
    @Environment(\.isPreview) private var isPreview
    @Environment(\.dismiss) private var dismiss
    
    private let jumboService = JumboService()
    private let tealColor = Color(UIColor.systemTeal)
    
    var body: some View {
        NavigationView {
            ZStack {
                if showLoading {
                    loadingView
                } else {
                    ZStack {
                        productListView
                        
                        VStack {
                            Spacer()
                            addToBasketButton
                        }
                    }
                }
            }
            .navigationTitle("Product Verification")            
            .navigationBarTitleDisplayMode(.large)
            
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(tealColor)
                }
            }
            .onAppear {
                if isPreview {
                    setupForPreview()
                } else {
                    checkProducts()
                }
            }
            .alert("Incomplete Verification", isPresented: $showWarningAlert) {
                Button("Continue Anyway", role: .destructive) {
                    addAllSelectedProducts()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("You haven't verified all unknown products yet. Only the products you've selected will be added to your basket. Continue anyway?")
            }
        }
    }
    
    private var addToBasketButton: some View {
        VStack(spacing: 0) {
            // Gradient overlay to fade content
            LinearGradient(
                colors: [Color(.systemBackground).opacity(0), Color(.systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 20)
            
            // Button container
            VStack(spacing: 12) {
                // Warning text if not all items are verified
                if !unknownProducts.isEmpty && selectedProducts.count < unknownProducts.count {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.orange)
                        
                        Text("\(unknownProducts.count - selectedProducts.count) item(s) still need verification")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.orange.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.orange.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                
                // Add to basket button
                Button(action: handleAddToBasket) {
                    HStack(spacing: 12) {
                        if isAddingProducts {
                            ProgressView()
                                .scaleEffect(0.9)
                                .tint(.white)
                        } else {
                            Image(systemName: "basket.fill")
                                .font(.system(size: 16, weight: .medium))
                        }
                        
                        Text(isAddingProducts ? "Adding to Basket..." : "Add to Basket")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: buttonEnabled ? [tealColor, tealColor.opacity(0.8)] : [Color(.systemGray4), Color(.systemGray3)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .shadow(color: buttonEnabled ? tealColor.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
                }
                .disabled(!buttonEnabled || isAddingProducts)
                .animation(.easeInOut(duration: 0.2), value: buttonEnabled)
                .animation(.easeInOut(duration: 0.2), value: isAddingProducts)
                
                // Selection summary
                if !unknownProducts.isEmpty {
                    Text("\(selectedProducts.count) of \(unknownProducts.count) products selected")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 34) // Extra padding for home indicator
            .background(Color(.systemBackground))
        }
    }
    
    private var buttonEnabled: Bool {
        return !selectedProducts.isEmpty || !knownProducts.isEmpty
    }
    
    private func handleAddToBasket() {
        
        // Check if all unknown products are verified
        if !unknownProducts.isEmpty && selectedProducts.count < unknownProducts.count {
            showWarningAlert = true
        } else {
            addAllSelectedProducts()
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            ProgressView()
                .scaleEffect(1.2)
                .tint(tealColor)
            
            VStack(spacing: 8) {
                Text("Checking products...")
                    .font(.system(size: 18, weight: .medium))
                
                Text("We're verifying which products we already know")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
    }
    
    private var productListView: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                // Summary card
                summaryCard
                    .padding(.horizontal, 16)
                
                // Unknown products section (needs verification) - shown first
                if !unknownProducts.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        sectionHeader(title: "Needs Verification", count: unknownProducts.count, icon: "exclamationmark.circle.fill", iconColor: .orange)
                        
                        ForEach(unknownProducts, id: \.self) { product in
                            UnknownProductCard(
                                productName: product,
                                searchResults: searchResults[product] ?? [],
                                selectedProduct: selectedProducts[product],
                                isExpanded: expandedProducts.contains(product),
                                onToggleExpanded: { toggleExpanded(product) },
                                onSelectProduct: { selectedProduct in
                                    selectProduct(product, selectedProduct)
                                },
                                onSearchMore: { searchForProduct(product) }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                // Known products section
                if !knownProducts.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        sectionHeader(title: "Already in Database", count: knownProducts.count, icon: "checkmark.circle.fill", iconColor: .green)
                        
                        ForEach(knownProducts, id: \.self) { product in
                            KnownProductCard(productName: product)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                // Bottom spacing for fixed button
                Color.clear.frame(height: 160)
            }
            .padding(.top, 8)
        }
    }
    
    private var summaryCard: some View {
        VStack(spacing: 0) {
            // Top section with statistics
            HStack(spacing: 0) {
                // Unknown products - Priority section
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(.orange.opacity(0.15))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.orange)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(unknownProducts.count)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Need verification")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Divider
                Rectangle()
                    .fill(Color(.systemGray4))
                    .frame(width: 1, height: 30)
                
                Spacer()
                
                // Progress indicator
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Text("\(selectedProducts.count)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(tealColor)
                        
                        Text("of")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        
                        Text("\(unknownProducts.count)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Text("selected")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Divider
                Rectangle()
                    .fill(Color(.systemGray4))
                    .frame(width: 1, height: 30)
                
                Spacer()
                
                // Known products
                HStack(spacing: 12) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(knownProducts.count)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Ready to use")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    ZStack {
                        Circle()
                            .fill(.green.opacity(0.15))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.green)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            // Progress bar section
            if !unknownProducts.isEmpty {
                VStack(spacing: 8) {
                    Divider()
                        .padding(.horizontal, 20)
                    
                    HStack(spacing: 12) {
                        // Progress ring
                        ZStack {
                            Circle()
                                .stroke(Color(.systemGray5), lineWidth: 3)
                                .frame(width: 24, height: 24)
                            
                            Circle()
                                .trim(from: 0, to: CGFloat(selectedProducts.count) / CGFloat(max(unknownProducts.count, 1)))
                                .stroke(tealColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                                .frame(width: 24, height: 24)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut(duration: 0.5), value: selectedProducts.count)
                        }
                        
                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemGray5))
                                    .frame(height: 6)
                                
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        LinearGradient(
                                            colors: [tealColor.opacity(0.8), tealColor],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(
                                        width: geometry.size.width * CGFloat(selectedProducts.count) / CGFloat(max(unknownProducts.count, 1)),
                                        height: 6
                                    )
                                    .animation(.easeInOut(duration: 0.5), value: selectedProducts.count)
                            }
                        }
                        .frame(height: 6)
                        
                        // Percentage
                        Text("\(Int((Double(selectedProducts.count) / Double(max(unknownProducts.count, 1))) * 100))%")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(tealColor)
                            .frame(width: 35, alignment: .trailing)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(.systemGray5), lineWidth: 0.5)
                )
        )
        .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 4)
        .shadow(color: .black.opacity(0.08), radius: 1, x: 0, y: 1)
    }
    
    private func sectionHeader(title: String, count: Int, icon: String, iconColor: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.system(size: 16, weight: .medium))
            
            Text(title)
                .font(.system(size: 20, weight: .semibold))
            
            Text("(\(count))")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
    
    // MARK: - Computed Properties
    
    private var knownProducts: [String] {
        productLinesWithStatus.compactMap { key, value in
            value == .known ? key : nil
        }
    }
    
    private var unknownProducts: [String] {
        productLinesWithStatus.compactMap { key, value in
            value == .unknown ? key : nil
        }
    }
    
    // MARK: - Functions
    
    private func toggleExpanded(_ product: String) {
        withAnimation(.easeInOut(duration: 0.3)) {
            if expandedProducts.contains(product) {
                expandedProducts.remove(product)
            } else {
                expandedProducts.insert(product)
                // Auto-search if we don't have results yet
                if searchResults[product]?.isEmpty ?? true {
                    searchForProduct(product)
                }
            }
        }
    }
    
    private func selectProduct(_ originalName: String, _ selectedProduct: JumboProduct?) {
        if let product = selectedProduct {
            selectedProducts[originalName] = product
        } else {
            selectedProducts.removeValue(forKey: originalName)
        }
    }
    
    private func searchForProduct(_ productName: String) {
        Task {
            do {
                let response = try await jumboService.searchProducts(query: productName)
                
                await MainActor.run {
                    searchResults[productName] = response.products.data.filter { $0.available }
                }
            } catch {
                print("Search error for \(productName): \(error)")
            }
        }
    }
    
    private func checkProducts() {
        Task {
            showLoading = true
            
            for productName in productLines {
                productLinesWithStatus[productName] = await ProductSearchHandler.checkSingleProduct(productName: productName)
            }
            
            showLoading = false
        }
    }
    
    private func addAllSelectedProducts() {
        isAddingProducts = true
        
        Task{
            let result = await ProductSearchHandler.addAllSelectedProducts(selectedProducts: selectedProducts, knownProducts: knownProducts)
            
            if (result) {
                dismiss()
            }
            
            isAddingProducts = false
        }
    }
    
    private func setupForPreview() {
        let products = productLines
        for (index, product) in products.enumerated() {
            productLinesWithStatus[product] = index % 3 == 0 ? .known : .unknown
        }
        showLoading = false
        
        // Add some mock search results for preview
        searchResults["Kaasstengels"] = [
            JumboProduct(
                id: "1",
                title: "Jumbo Kaasstengels 100g",
                quantity: "100g",
                prices: JumboProduct.Prices(price: JumboProduct.Prices.Price(amount: 299, unitSize: "100g")),
                imageInfo: nil,
                available: true
            ),
            JumboProduct(
                id: "2",
                title: "AH Kaasstengels 150g",
                quantity: "150g",
                prices: JumboProduct.Prices(price: JumboProduct.Prices.Price(amount: 349, unitSize: "150g")),
                imageInfo: nil,
                available: true
            )
        ]
    }
}

// MARK: - Product Cards

struct KnownProductCard: View {
    let productName: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Product icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 52, height: 52)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.green)
            }
            
            // Product details
            VStack(alignment: .leading, spacing: 4) {
                Text(productName)
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(2)
                
                HStack(spacing: 6) {
                    Text("Already in database")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Text("Ready to use")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.green)
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct UnknownProductCard: View {
    let productName: String
    let searchResults: [JumboProduct]
    let selectedProduct: JumboProduct?
    let isExpanded: Bool
    let onToggleExpanded: () -> Void
    let onSelectProduct: (JumboProduct?) -> Void
    let onSearchMore: () -> Void
    
    private let tealColor = Color(UIColor.systemTeal)
    
    var body: some View {
        VStack(spacing: 0) {
            // Main card
            Button(action: onToggleExpanded) {
                HStack(spacing: 16) {
                    // Product icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedProduct != nil ? tealColor.opacity(0.2) : Color.orange.opacity(0.2))
                            .frame(width: 52, height: 52)
                        
                        Image(systemName: selectedProduct != nil ? "checkmark.circle.fill" : "questionmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(selectedProduct != nil ? tealColor : .orange)
                    }
                    
                    // Product details
                    VStack(alignment: .leading, spacing: 4) {
                        Text(productName)
                            .font(.system(size: 16, weight: .semibold))
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        HStack(spacing: 6) {
                            if let selected = selectedProduct {
                                Text("Selected:")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                
                                Text(selected.title)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(tealColor)
                                    .lineLimit(1)
                            } else {
                                Text("Needs verification")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                
                                Text("•")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                
                                Text("Tap to search")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)
                }
                .padding(16)
            }
            .buttonStyle(PlainButtonStyle())
            .background(Color(.systemBackground))
            
            if isExpanded {
                VStack(spacing: 0) {
                    Divider()
                    
                    if searchResults.isEmpty {
                        HStack(spacing: 12) {
                            ProgressView()
                                .scaleEffect(0.8)
                                .tint(tealColor)
                            
                            Text("Searching for products...")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            
                            Spacer()
                        }
                        .padding(20)
                        .background(Color(.systemGray6))
                    } else {
                        LazyVStack(spacing: 0) {
                            ForEach(searchResults, id: \.id) { product in
                                ProductResultRow(
                                    product: product,
                                    isSelected: selectedProduct?.id == product.id,
                                    onSelect: {
                                        if selectedProduct?.id == product.id {
                                            onSelectProduct(nil)
                                        } else {
                                            onSelectProduct(product)
                                        }
                                    }
                                )
                                
                                if product.id != searchResults.last?.id {
                                    Divider()
                                        .padding(.leading, 68)
                                }
                            }
                        }
                        .background(Color(.systemGray6))
                    }
                }
            }
        }
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .animation(.easeInOut(duration: 0.3), value: isExpanded)
    }
}

struct ProductResultRow: View {
    let product: JumboProduct
    let isSelected: Bool
    let onSelect: () -> Void
    
    private let tealColor = Color(UIColor.systemTeal)
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Product image
                AsyncImage(url: URL(string: product.imageUrl ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                                .font(.system(size: 16))
                        )
                }
                .frame(width: 44, height: 44)
                .cornerRadius(8)
                
                // Product details
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.title)
                        .font(.system(size: 15, weight: .medium))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: 6) {
                        Text(product.displayPrice)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.green)
                        
                        if let quantity = product.quantity {
                            Text("•")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            
                            Text(quantity)
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                // Selection indicator
                ZStack {
                    Circle()
                        .fill(isSelected ? tealColor : Color.clear)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Circle()
                                .stroke(isSelected ? tealColor : Color(.systemGray4), lineWidth: 2)
                        )
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(isSelected ? tealColor.opacity(0.1) : Color.clear)
    }
}

// MARK: - Environment Key for Preview Detection

private struct IsPreviewKey: EnvironmentKey {
    static let defaultValue: Bool = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
}

extension EnvironmentValues {
    var isPreview: Bool {
        get { self[IsPreviewKey.self] }
        set { self[IsPreviewKey.self] = newValue }
    }
}

#Preview {
    let productLines: [String] = ["Jumbo Cola", "Kaasstengels", "Pepsi", "Albert Heijn Milk"]
    CheckProductsView(productLines: productLines)
}
