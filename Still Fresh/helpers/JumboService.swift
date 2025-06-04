import Foundation

class JumboService {
    private let baseUrl = "https://mobileapi.jumbo.com"
    private let apiVersion = "v17"
    private let headers = [
        "User-Agent": "Mozilla/5.0",
        "Accept": "application/json"
    ]
    
    func searchProducts(query: String) async throws -> JumboSearchResponse {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "\(baseUrl)/\(apiVersion)/search?q=\(encodedQuery)&offset=0&limit=20"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        headers.forEach { request.addValue($1, forHTTPHeaderField: $0) }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let searchResponse = try JSONDecoder().decode(JumboSearchResponse.self, from: data)
        return searchResponse
    }
}
