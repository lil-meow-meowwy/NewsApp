import Foundation

struct NewsResponse: Codable {
    let status: String
    let totalResults: Int?
    let articles: [Article]
}

struct Article: Codable, Identifiable, Equatable {
    let id = UUID()
    let source: Source
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
    let content: String?
    
    enum CodingKeys: String, CodingKey {
        case source, author, title, description, url, urlToImage, publishedAt, content
    }
    
    static func == (lhs: Article, rhs: Article) -> Bool {
        lhs.id == rhs.id && lhs.url == rhs.url
    }
}

struct Source: Codable {
    let id: String?
    let name: String
}
