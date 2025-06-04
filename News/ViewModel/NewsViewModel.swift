import Foundation

@MainActor
class NewsViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var currentPage = 1
    @Published var canLoadMore = true
    @Published var currentQuery: String? = nil
    @Published var currentCategory: Category?

    private let newsService = NewsService()
    private let storageService = NewsStorageService()

    func loadArticles(query: String? = nil, category: Category? = nil, isRefreshing: Bool = false) {
        guard !isLoading else { return }

        if isRefreshing {
            currentPage = 1
            canLoadMore = true
        }

        currentCategory = category
        currentQuery = query

        Task {
            do {
                isLoading = true
                if isRefreshing {
                    articles = []
                }

                let response = try await newsService.fetchTopHeadlines(
                    page: currentPage,
                    category: category,
                    query: query
                )

                await MainActor.run {
                    if isRefreshing {
                        articles = response.articles
                    } else {
                        articles += response.articles
                    }
                    error = nil
                    canLoadMore = !response.articles.isEmpty
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
        loadArticles(query: currentQuery, category: currentCategory)
    }

    func refresh() {
        loadArticles(query: currentQuery, category: currentCategory, isRefreshing: true)
    }
}
