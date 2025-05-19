//
//  CheckProductsInView.swift
//  Still Fresh
//
//  Created by Gideon Dijkhuis on 15/05/2025.
//

import SwiftUI
import Foundation

struct CheckProductsView: View {
    @State var productLines: [String]
    @State private var showLoading = true
    @State private var knownProducts: [String] = []
    @State private var unknownProducts: [String] = []

    var body: some View {
        VStack {
            if (showLoading) {
                ProgressView()
                Text("We are checking if we know these products already").padding()
            } else {
                Text("Known products")
                    .font(.title)
                    .padding()

                if !knownProducts.isEmpty {
                    List(knownProducts, id: \.self) { product in Text(product)
                    }
                } else {
                    Text("Unfortunately we don't know any of these products. Check them below").padding()
                }
                
                Text("Unknown products")
                    .font(.title)
                    .padding()
                
                if !unknownProducts.isEmpty {
                    List(unknownProducts, id: \.self) {
                        product in Button(product) {
                            
                        }
                    }
                } else {
                    Text("Good news! We know al products on your receipt!").padding()
                }
                
                Button("Gereed") {
                    
                }
                .padding()
                .frame(minWidth: 120)
                .background(Color(red: 0.04, green: 0.29, blue: 0.29))
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.bottom)
            }
        }.onAppear {
            checkProducts()
        }
    }
    
    private func checkProducts() {
        Task {
            showLoading = true
            
            for productName in productLines {
                do {
                    try await SupaClient
                        .from("product_receipt_names")
                        .select()
                        .eq("product_receipt_name", value: productName)
                        .limit(1)
                        .single()
                        .execute()
                        .value
                    
                    knownProducts.append(productName)
                } catch {
                    unknownProducts.append(productName)
                }
            }
            
            showLoading = false
            
        }
    }
}

#Preview {
    let productLines: [String] = ["Jumbo Cola", "Kaasstengels"]
    CheckProductsView(productLines: productLines)
}
