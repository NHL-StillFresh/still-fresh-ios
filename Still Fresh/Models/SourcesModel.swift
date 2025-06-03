//
//  SourcesModel.swift
//  Still Fresh
//
//  Created by Jesse van der Voet on 19/05/2025.
//

struct SourceModel: Decodable {
    let sourceId: String
    let sourceLocation: String?
    let createdAt: String
    let updatedAt: String?
}
