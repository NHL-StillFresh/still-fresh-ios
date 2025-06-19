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
            Task {
               await fetchTipsFromAPI()
            }
        }
    }
    
    func forceRefreshTips() {
        guard !isLoading else { return }
        isLoading = true
        error = nil
        Task {
           await fetchTipsFromAPI()
        }
    }
    
    private func fetchTipsFromAPI() async {
        guard let request = AIHandler.buildOpenRouterRequest(apiKey: apiKey, messages: AIHandler.createFoodTipsPrompt()) else {
            self.error = "Invalid API request"
            self.isLoading = false
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(for: request)

            guard let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = jsonResponse["choices"] as? [[String: Any]],
                  let firstChoice = choices.first,
                  let message = firstChoice["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                self.error = "Invalid response format"
                return
            }

            let tips = self.parseTipsFromResponse(content)
            
            self.dailyTips = DailyTips(
                date: Date(),
                tips: tips.map { FoodSavingTip(content: $0) }
            )
            self.cacheTips()
            return
        } catch {
            self.error = "Error fetching data: \(error.localizedDescription)"
        }

        self.isLoading = false
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
