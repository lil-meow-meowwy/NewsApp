import XCTest
import CoreData
@testable import News

class NewsStorageServiceTests: XCTestCase {
    var storageService: NewsStorageService!
    var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        let persistence = PersistenceController(inMemory: true)
        context = persistence.container.viewContext
        storageService = NewsStorageService(context: context)
    }
    
    func testSaveAndFetchArticles() {
        let testArticle = Article(
            source: Source(id: nil, name: "Test Source"),
            author: "Test Author",
            title: "Test Title",
            description: "Test Description",
            url: "https://test.com",
            urlToImage: nil,
            publishedAt: "2023-01-01T00:00:00Z",
            content: "Test Content"
        )
        
        storageService.saveArticles([testArticle])
        let fetchedArticles = storageService.fetchArticles(page: 1, pageSize: 10)
        
        XCTAssertEqual(fetchedArticles.count, 1, "Should fetch 1 article")
        XCTAssertEqual(fetchedArticles.first?.title, "Test Title", "Titles should match")
    }
}
