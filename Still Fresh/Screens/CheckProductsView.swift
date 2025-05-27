//
//  CheckProductsInView.swift
//  Still Fresh
//
//  Created by Gideon Dijkhuis on 15/05/2025.
//

import SwiftUI
import Foundation
import Supabase

enum ProductKnownStatus: CaseIterable {
    case known, unknown
}

struct CheckProductsView: View {
    @State var productLines: [String]
    @State private var productLinesWithStatus: [String: ProductKnownStatus] = [:]
    @State private var showLoading = true
    @State private var showProductVerifySheet: Bool = false
    @State private var knownProducts: [String] = []
    @State private var unknownProducts: [String] = []
    @State private var productToVerify: String? = nil

    var body: some View {
        VStack {
            if (showLoading) {
                ProgressView()
                Text("We are checking if we know these products already").padding()
            } else {
                Text("Products")
                    .font(.title)
                    .padding()
                
                if (productLinesWithStatus.isEmpty) {
                    Text("There are no products to show")
                } else {
                    NavigationView{
                        List(Array(productLinesWithStatus.keys), id: \.self) { key in
                            
                            let icon: String = productLinesWithStatus[key] == .unknown ? "exclamationmark.circle.fill" : "checkmark.circle.fill"
                            let color: Color = productLinesWithStatus[key] == .unknown ? Color.red : Color.green
                            
                            if (productLinesWithStatus[key] == .unknown) {
                                let productName = key
                                NavigationLink(
                                    destination: ProductSearchDestination(productName: productName)
                                ) {
                                    SettingRow(icon: icon, iconColor: color, title: key)
                                }
                            }
                            else {
                                SettingRow(icon: icon, iconColor: color, title: key)
                            }

                        }
                    }
                }

                Button("Next") {
                    
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
                    let product: ProductReceiptNameModel = try await SupaClient
                        .from("product_receipt_names")
                        .select()
                        .eq("product_receipt_name", value: productName)
                        .limit(1)
                        .single()
                        .execute()
                        .value
                                        
                    let productKnownName: ProductModel = try await SupaClient
                        .from("products")
                        .select()
                        .eq("product_id", value: product.product_id)
                        .limit(1)
                        .single()
                        .execute()
                        .value
                    
                    productLinesWithStatus[productKnownName.product_name] = .known
                    
                } catch {
                    productLinesWithStatus[productName] = .unknown
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
