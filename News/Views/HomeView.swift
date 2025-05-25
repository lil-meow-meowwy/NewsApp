import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = NewsViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            ArticleListView(articles: viewModel.articles,
                          isLoading: viewModel.isLoading,
                          error: viewModel.error,
                          onRefresh: viewModel.refresh,
                          onLoadMore: viewModel.loadNextPage)
            .navigationTitle("Top Headlines")
            .searchable(text: $searchText, prompt: "Search news...")
            .onSubmit(of: .search) {
                viewModel.loadArticles(isRefreshing: true)
            }
            .onChange(of: searchText) { newValue in
                if newValue.isEmpty {
                    viewModel.loadArticles(isRefreshing: true)
                }
            }
        }
        .onAppear {
            if viewModel.articles.isEmpty {
                viewModel.loadArticles()
            }
        }
    }
}
