import Foundation
import SwiftUI
import Combine

class FoodTipsViewModel: ObservableObject {
    @Published var dailyTips: DailyTips = DailyTips.empty
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    
    private let apiKey: String = APIKeys.openRouterAPIKey
    private var cancellables = Set<AnyCancellable>()
    private var refreshTimer: Timer?
    private let userDefaults = UserDefaults.standard
    private let tipsCacheKey = "dailyFoodSavingTips"
    
    init() {
        loadCachedTips()
        
        if shouldGenerateNewTips() {
            generateTips()
        }
        
        scheduleNextMidnightRefresh()
    }
    
    deinit {
        refreshTimer?.invalidate()
    }
    
    private func loadCachedTips() {
        if let data = userDefaults.data(forKey: tipsCacheKey),
           let cachedTips = try? JSONDecoder().decode(DailyTips.self, from: data) {
            self.dailyTips = cachedTips
        }
    }
    
    private func cacheTips() {
        if let data = try? JSONEncoder().encode(dailyTips) {
            userDefaults.set(data, forKey: tipsCacheKey)
        }
    }
    
    private func shouldGenerateNewTips() -> Bool {
        let calendar = Calendar.current
        return dailyTips.tips.isEmpty || !calendar.isDateInToday(dailyTips.date)
    }
    
    func generateTips() {
        guard !isLoading else { return }
        
        if shouldGenerateNewTips() {
            fetchTipsFromAPI()
        }
    }
    
    func forceRefreshTips() {
        guard !isLoading else { return }
        isLoading = true
        error = nil
        fetchTipsFromAPI()
    }
    
    private func fetchTipsFromAPI() {
        guard let request = AIHandler.buildOpenRouterRequest(apiKey: apiKey, messages: AIHandler.makeFoodTipsPrompt()) else {
            self.error = "Invalid API request"
            self.isLoading = false
            return
        }
        
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
                
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Raw API Response: \(responseString)")
                }
                
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    
                    if let choices = jsonResponse?["choices"] as? [[String: Any]],
                       let firstChoice = choices.first,
                       let message = firstChoice["message"] as? [String: Any],
                       let content = message["content"] as? String {
                        
                        let tips = self.parseTipsFromResponse(content)
                        
                        self.dailyTips = DailyTips(
                            date: Date(),
                            tips: tips.map { FoodSavingTip(content: $0) }
                        )
                        self.cacheTips()
                        return
                    }
                    
                    if let error = jsonResponse?["error"] as? [String: Any],
                       let message = error["message"] as? String {
                        self.error = "API Error: \(message)"
                        if self.dailyTips.tips.isEmpty {
                            self.useFallbackTips()
                        }
                        return
                    }
                    
                    self.error = "Could not parse response"
                    if self.dailyTips.tips.isEmpty {
                        self.useFallbackTips()
                    }
                    
                } catch {
                    self.error = "Failed to parse JSON: \(error.localizedDescription)"
                    if self.dailyTips.tips.isEmpty {
                        self.useFallbackTips()
                    }
                }
            }
        }
        
        task.resume()
    }
    
    private func parseTipsFromResponse(_ response: String) -> [String] {
        response
            .components(separatedBy: .newlines)
            .compactMap { line in
                let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.isEmpty { return nil }
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
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) else { return }
        let midnight = calendar.startOfDay(for: tomorrow).addingTimeInterval(1)
        
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
