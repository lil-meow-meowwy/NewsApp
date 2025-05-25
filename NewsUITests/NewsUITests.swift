import XCTest

final class NewsUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("--uitesting")
        app.launch()
    }
    
    func testCategorySelectionAndArticleDisplay() {
        app.tabBars.buttons["Categories"].tap()
        
        XCTAssertTrue(app.navigationBars["Categories"].exists)
        
        let technologyButton = app.buttons["technology_category_button"]
        XCTAssertTrue(technologyButton.waitForExistence(timeout: 20))
        technologyButton.tap()
        
        let firstArticle = app.staticTexts.element(boundBy: 2)
        let exists = firstArticle.waitForExistence(timeout: 10)
        XCTAssertTrue(exists, "Articles not loading after selecting a category")
        
        let articles = app.staticTexts.matching(identifier: "article_title")
        XCTAssertGreaterThan(articles.count, 0, "No articles found")
        
        if articles.count > 0 {
            let firstArticleTitle = articles.firstMatch.label
            XCTAssertFalse(firstArticleTitle.isEmpty, "The article title is empty")
        }
    }
    
    func testHomeScreenArticles() {
        let homeTab = app.tabBars.buttons["Home"]
        XCTAssertTrue(homeTab.exists)
        
        let articles = app.staticTexts.matching(identifier: "article_title")
        let exists = articles.firstMatch.waitForExistence(timeout: 10)
        XCTAssertTrue(exists, "There are no articles on the main page")
    }
    
    func testSearchFunctionality() {
        app.tabBars.buttons["Home"].tap()
        
        let searchField = app.searchFields["Search news..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        
        searchField.typeText("Ukraine")
        
        app.keyboards.buttons["Search"].tap()
        
        let firstResult = app.staticTexts.matching(identifier: "article_title").firstMatch
        XCTAssertTrue(firstResult.waitForExistence(timeout: 10))
    }
}
