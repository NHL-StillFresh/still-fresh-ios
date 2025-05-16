//
//  ProductObject.swift
//  Still Fresh
//
//  Created by Gideon Dijkhuis on 16/05/2025.
//

import SwiftUI

struct Product: Decodable {
    let product_name: String
    let product_image: String?
    let product_code: String?
    let product_expiration_in_days: Int?
    let product_nutritional_value: String?
    let source_id: UUID?
    let created_at: Date?
    let updated_at: String?
    let product_id: UUID
}
