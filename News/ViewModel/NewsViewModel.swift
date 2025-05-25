import Foundation

@MainActor
class NewsViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var currentPage = 1
    @Published var canLoadMore = true
    
    private let newsService = NewsService()
    private let storageService = NewsStorageService()
    private var currentCategory: Category?
    
    func loadArticles(category: Category? = nil, isRefreshing: Bool = false) {
        guard !isLoading else { return }
        
        if isRefreshing {
            currentPage = 1
            canLoadMore = true
        }
        
        currentCategory = category
        
        Task {
            do {
                isLoading = true
                if isRefreshing {
                    articles = []
                }
                
                let localArticles = storageService.fetchArticles(
                    for: category?.rawValue,
                    page: currentPage,
                    pageSize: 20
                )
                
                if !localArticles.isEmpty {
                    articles = isRefreshing ? localArticles : articles + localArticles
                }
                
                let response = try await newsService.fetchTopHeadlines(
                    page: currentPage,
                    category: category
                )
                
                await MainActor.run {
                    articles = response.articles
                    currentCategory = category
                    error = nil
                }
                print("Articles loaded: \(response.articles.count)")
            } catch {
                await MainActor.run {
                    self.error = error
                }
                print("Error loading articles: \(error)")
            }
            
            await MainActor.run {
                isLoading = false
            }
        }
    }
    
    func loadNextPage() {
        guard !isLoading && canLoadMore else { return }
        currentPage += 1
        loadArticles(category: currentCategory)
    }
    
    func refresh() {
        loadArticles(category: currentCategory, isRefreshing: true)
    }
}
