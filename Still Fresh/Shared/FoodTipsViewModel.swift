import Foundation
import SwiftUI
import Combine

class FoodTipsViewModel: ObservableObject {
    @Published var dailyTips: DailyTips = DailyTips.empty
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    
    private let apiKey: String
    private let openRouterEndpoint = "https://openrouter.ai/api/v1/chat/completions"
    private let modelName = "mistralai/mistral-small-3.1-24b-instruct:free"
    
    private var cancellables = Set<AnyCancellable>()
    private var refreshTimer: Timer?
    private let userDefaults = UserDefaults.standard
    private let tipsCacheKey = "dailyFoodSavingTips"
    
    init(apiKey: String) {
        self.apiKey = apiKey
        loadCachedTips()
        
        // Check if we need to refresh at startup
        if shouldGenerateNewTips() {
            generateTips()
        }
        
        // Set up midnight refresh
        scheduleNextMidnightRefresh()
    }
    
    deinit {
        refreshTimer?.invalidate()
    }
    
    private func loadCachedTips() {
        guard let data = userDefaults.data(forKey: tipsCacheKey),
              let cachedTips = try? JSONDecoder().decode(DailyTips.self, from: data) else {
            return
        }
        
        self.dailyTips = cachedTips
    }
    
    private func cacheTips() {
        guard let data = try? JSONEncoder().encode(dailyTips) else { return }
        userDefaults.set(data, forKey: tipsCacheKey)
    }
    
    private func shouldGenerateNewTips() -> Bool {
        let calendar = Calendar.current
        return dailyTips.tips.isEmpty || !calendar.isDateInToday(dailyTips.date)
    }
    
    func generateTips() {
        guard !isLoading else { return }
        
        // Only generate if we need new tips (empty or from a previous day)
        if shouldGenerateNewTips() {
            fetchTipsFromAPI()
        }
    }
    
    // New method to force refresh regardless of cache state
    func forceRefreshTips() {
        guard !isLoading else { return }
        isLoading = true
        error = nil
        fetchTipsFromAPI()
    }
    
    private func fetchTipsFromAPI() {
        let prompt = """
        You are a helpful assistant that gives short, practical food-saving tips.

        Generate 6 different, simple, and creative food-saving tips. Each tip should be no more than 10 words. Tips must help people prevent food from going bad or expiring too soon.

        Respond with just the 6 tips, numbered, each on a new line. Do not add extra commentary.

        Example:  
        1. Store onions in a cool, dry, ventilated space.  
        2. Keep herbs fresh in a jar with water.  
        3. Freeze leftover fruit for smoothies or baking.  

        Now generate today's 6 tips.
        """
        
        let messages: [[String: Any]] = [
            ["role": "system", "content": "You are a helpful assistant."],
            ["role": "user", "content": prompt]
        ]
        
        // Updated request body to match OpenRouter's expected format
        let body: [String: Any] = [
            "model": modelName,
            "messages": messages,
            "max_tokens": 200,
            "temperature": 0.7,
            "top_p": 1,
            "stream": false
        ]
        
        guard let url = URL(string: openRouterEndpoint) else {
            self.error = "Invalid API endpoint"
            self.isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("still-fresh-ios", forHTTPHeaderField: "HTTP-Referer")
        request.addValue("https://stillfresh.app", forHTTPHeaderField: "OpenRouter-Referrer")
        request.addValue("StillFresh iOS App", forHTTPHeaderField: "User-Agent")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            // Debug the request body
            if let requestBodyString = String(data: request.httpBody!, encoding: .utf8) {
                print("Request Body: \(requestBodyString)")
            }
        } catch {
            self.error = "Failed to create request: \(error.localizedDescription)"
            self.isLoading = false
            return
        }
        
        // Use a more direct approach to debug the API response
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.error = "Network error: \(error.localizedDescription)"
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.error = "Invalid response"
                    return
                }
                
                print("Response status code: \(httpResponse.statusCode)")
                
                guard let data = data, !data.isEmpty else {
                    self.error = "Empty response"
                    return
                }
                
                // Print the raw response for debugging
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Raw API Response: \(responseString)")
                }
                
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    print("JSON Response: \(jsonResponse ?? [:])")
                    
                    if let choices = jsonResponse?["choices"] as? [[String: Any]],
                       let firstChoice = choices.first,
                       let message = firstChoice["message"] as? [String: Any],
                       let content = message["content"] as? String {
                        
                        print("Content from manual parsing: \(content)")
                        let tips = self.parseTipsFromResponse(content)
                        
                        self.dailyTips = DailyTips(
                            date: Date(),
                            tips: tips.map { FoodSavingTip(content: $0) }
                        )
                        
                        self.cacheTips()
                        
                        // Ensure we set isLoading to false
                        self.isLoading = false
                        return
                    }
                    
                    // Check for error in the response
                    if let error = jsonResponse?["error"] as? [String: Any],
                       let message = error["message"] as? String {
                        self.error = "API Error: \(message)"
                        
                        // If we have an error but no existing tips, use fallback tips
                        if self.dailyTips.tips.isEmpty {
                            self.useFallbackTips()
                        }
                        return
                    }
                    
                    self.error = "Could not parse response"
                    
                    // If we can't parse but have no existing tips, use fallback tips
                    if self.dailyTips.tips.isEmpty {
                        self.useFallbackTips()
                    }
                } catch {
                    self.error = "Failed to parse JSON: \(error.localizedDescription)"
                    
                    // If parsing fails but we have no existing tips, use fallback tips
                    if self.dailyTips.tips.isEmpty {
                        self.useFallbackTips()
                    }
                }
            }
        }
        
        task.resume()
        
    }
    
    private func parseTipsFromResponse(_ response: String) -> [String] {
        let lines = response.components(separatedBy: .newlines)
        
        return lines.compactMap { line -> String? in
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty { return nil }
            
            // Strip off number prefix if present (like "1. " or "1) ")
            let pattern = "^\\d+[.)]\\s+"
            if let range = trimmed.range(of: pattern, options: .regularExpression) {
                return String(trimmed[range.upperBound...])
            }
            return trimmed
        }
    }
    
    private func scheduleNextMidnightRefresh() {
        refreshTimer?.invalidate()
        
        let calendar = Calendar.current
        let now = Date()
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) else {
            return
        }
        
        var midnight = calendar.startOfDay(for: tomorrow)
        
        // Add a small delay to ensure we're past midnight
        midnight = midnight.addingTimeInterval(1)
        
        let timeInterval = midnight.timeIntervalSince(now)
        refreshTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] _ in
            self?.generateTips()
            self?.scheduleNextMidnightRefresh()
        }
    }
    
    private func useFallbackTips() {
        let fallbackTips = [
            "Store onions in a cool, dry, ventilated space.",
            "Keep herbs fresh in a jar with water.",
            "Freeze leftover fruit for smoothies or baking.",
            "Store lettuce with paper towel to absorb moisture.",
            "Use airtight containers for leftovers.",
            "Keep dairy products in coldest part of fridge."
        ]
        
        self.dailyTips = DailyTips(
            date: Date(),
            tips: fallbackTips.map { FoodSavingTip(content: $0) }
        )
        
        self.cacheTips()
        self.isLoading = false
    }
}

// MARK: - API Response Types
struct OpenRouterResponse: Decodable {
    let id: String
    let choices: [Choice]
    
    struct Choice: Decodable {
        let message: Message
        let index: Int
        
        enum CodingKeys: String, CodingKey {
            case message, index
        }
    }
    
    struct Message: Decodable {
        let content: String
        let role: String
        
        enum CodingKeys: String, CodingKey {
            case content, role
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, choices
    }
} 
