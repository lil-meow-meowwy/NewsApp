import Foundation

class NewsService {
    private let apiKey = "c1761556e50a4ae6bfa92c5b721f3070"
    private let baseUrl = "https://newsapi.org/v2/"
    private let pageSize = 20
    
    func fetchTopHeadlines(page: Int, category: Category? = nil, query: String? = nil) async throws -> NewsResponse {
        var urlString = "\(baseUrl)top-headlines?country=us&pageSize=\(pageSize)&page=\(page)"
        
        if let category = category {
            urlString += "&category=\(category.rawValue)"
        }
        
        if let query = query, !query.isEmpty {
            urlString += "&q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        }
        
        print("Fetching URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.addValue(apiKey, forHTTPHeaderField: "X-Api-Key")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(NewsResponse.self, from: data)
            print("Received \(response.articles.count) articles") // Логування
            return response
        } catch {
            print("Fetch error: \(error)")
            throw error
        }
    }
}
