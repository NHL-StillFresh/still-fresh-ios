//
//  AlertModel.swift
//  Still Fresh
//
//  Created by Gideon Dijkhuis on 10/06/2025.
//

// Alert item model
struct AlertModel: Codable, Identifiable {
    let id: Int
    let title: String
    let message: String
    let timeAgo: String
    let isRead: Bool
}
