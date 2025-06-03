import Foundation

struct JumboProduct: Codable, Identifiable {
    let id: String
    let title: String
    let quantity: String?
    let prices: Prices
    let imageInfo: ImageInfo?
    let available: Bool
    
    private enum CodingKeys: String, CodingKey {
        case id, title, quantity, prices, imageInfo
        case available = "available"
    }
    
    struct Prices: Codable {
        let price: Price
        
        struct Price: Codable {
            let amount: Double
            let unitSize: String?
        }
    }
    
    struct ImageInfo: Codable {
        let primaryView: [Image]
        
        struct Image: Codable {
            let url: String
        }
    }
    
    var displayPrice: String {
        return String(format: "€%.2f", prices.price.amount / 100)
    }
    
    var imageUrl: String? {
        return imageInfo?.primaryView.first?.url
    }
}

struct JumboSearchResponse: Codable {
    let products: Products
    
    struct Products: Codable {
        let data: [JumboProduct]
    }
    
    private enum CodingKeys: String, CodingKey {
        case products
    }
}
