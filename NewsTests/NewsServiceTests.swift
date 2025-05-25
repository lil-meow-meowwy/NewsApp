import XCTest
@testable import News

class NewsServiceTests: XCTestCase {
    var newsService: NewsService!
    
    override func setUp() {
        super.setUp()
        newsService = NewsService()
    }
    
    func testFetchTopHeadlines() async {
        do {
            let articles = try await newsService.fetchTopHeadlines(page: 1)
            XCTAssertFalse(articles.isEmpty, "Articles should not be empty")
        } catch {
            XCTFail("Failed to fetch headlines: \(error.localizedDescription)")
        }
    }

    func testFetchWithCategory() async {
        do {
            let articles = try await newsService.fetchTopHeadlines(page: 1, category: .technology)
            XCTAssertFalse(articles.isEmpty, "Technology articles should not be empty")
        } catch {
            XCTFail("Failed to fetch technology headlines: \(error.localizedDescription)")
        }
    }
}
