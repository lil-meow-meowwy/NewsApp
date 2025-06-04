import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = NewsViewModel()
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.articles) { article in
                    NavigationLink {
                        ArticleDetailView(article: article)
                    } label: {
                        ArticleRow(article: article)
                    }
                    .onAppear {
                        if article == viewModel.articles.last {
                            viewModel.loadNextPage()
                        }
                    }
                }

                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Top Headlines")
            .searchable(text: $searchText, prompt: "Search news...")
            .refreshable {
                viewModel.refresh()
            }
            .onSubmit(of: .search) {
                viewModel.loadArticles(query: searchText, isRefreshing: true)
            }
            .onChange(of: searchText) { newValue in
                if newValue.isEmpty {
                    viewModel.loadArticles(query: nil, isRefreshing: true)
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
