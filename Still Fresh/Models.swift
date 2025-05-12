//
//  Models.swift
//  Still Fresh
//
//  Created by Jesse van der Voet on 12/05/2025.
//

struct Users: Decodable {
    let user_id: String
    let user_email: String
}

struct Houses: Decodable {
    let house_id: String
    let house_address: String
    let house_name: String
    let house_image: String
    let created_at: String // Change this to a date format
    let updated_at: String // Change this to a date format
}

struct HouseMemberships: Decodable {
    let user_id: String
    let house_id: String
    let membership_join_date: String // Change this to a date format
    let membership_type: String // Change this to a enum
    let created_at: String // Change this to a date format
    let updated_at: String // Change this to a date format
}

struct HouseInventories: Decodable {
    let house_inventory_id: String
    let inventory_type: String // Change this to a enum
    let house_id: String
    let product_id: String
    let inventory_quantity: Int
    let inventory_best_before: String // Change this to a date format
    let inventory_purchase_date: String // Change this to a date format
    let inventory_storage_location: String
    let created_at: String // Change this to a date format
    let updated_at: String // Change this to a date format
}

struct Products: Decodable {
    let product_id: String
    let product_name: String
    let product_image: String
    let product_code: String
    let product_expiration_in_days: Int
    let product_nutritional_value: String // Will be stored as JSON so no idea how this will decode
    let created_at: String // Change this to a date format
    let updated_at: String // Change this to a date format
}

struct Sources: Decodable {
    let source_id: String
    let source_location: String
    let created_at: String // Change this to a date format
    let updated_at: String // Change this to a date format
}


