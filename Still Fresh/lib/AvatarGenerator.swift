//
//  UserImageGenerator.swift
//  Still Fresh
//
//  Created by Jesse van der Voet on 19/06/2025.
//

import Foundation


class AvatarGenerator {
    static let DICEBEAR_URL = "api.dicebear.com"
    static let DICEBEAR_API_VERSION = "9.x"
    static let DICEBEAR_IMAGE_FORMAT = "png"
    
    enum Category: String {
        case THUMBS = "thumbs"
        case EMOJI = "fun-emoji"
        case BOTTTS = "bottts-neutral"
    }
    
    static func generateAvatarImageURL(
        withName name: String,
        category: Category = .EMOJI
    ) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = DICEBEAR_URL
        urlComponents.path = "/\(DICEBEAR_API_VERSION)/\(category.rawValue)/\(DICEBEAR_IMAGE_FORMAT)"
        urlComponents.queryItems = [
            URLQueryItem(name: "seed", value: name)
        ]
        return urlComponents.url
    }
}

