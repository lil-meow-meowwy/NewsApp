import SwiftUI

struct ArticleListView: View {
    let articles: [Article]
    let isLoading: Bool
    let error: Error?
    let onRefresh: () -> Void
    let onLoadMore: () -> Void
    
    @EnvironmentObject var favoritesVM: FavoritesViewModel
    
    var body: some View {
        if let error = error {
            ErrorView(error: error, onRetry: onRefresh)
        } else if articles.isEmpty && isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if articles.isEmpty {
            Text("No articles found")
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List {
                ForEach(articles) { article in
                    ArticleRow(article: article, favoritesVM: favoritesVM)
                        .onAppear {
                            if articles.firstIndex(where: { $0.id == article.id }) == articles.count - 1 {
                                onLoadMore()
                            }
                        }
                }
                
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .listStyle(.plain)
            .refreshable {
                onRefresh()
            }
        }
    }
}

struct ArticleRow: View {
    let article: Article
    @ObservedObject var favoritesVM: FavoritesViewModel
    
    var body: some View {
        NavigationLink(destination: ArticleDetailView(article: article, favoritesVM: favoritesVM)) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(article.title)
                        .font(.headline)
                    
                    Spacer()
                    
                    if favoritesVM.isFavorite(article) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                    }
                }
                
                if let description = article.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            .padding()
            .contextMenu {
                Button(action: { favoritesVM.toggleFavorite(article) }) {
                    Label(
                        favoritesVM.isFavorite(article) ? "Видалити з обраного" : "Додати до обраного",
                        systemImage: favoritesVM.isFavorite(article) ? "heart.slash" : "heart"
                    )
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ErrorView: View {
    let error: Error
    let onRetry: () -> Void
    
    var body: some View {
        VStack {
            Text("Error loading articles")
                .font(.headline)
            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .padding()
            
            Button("Retry") {
                onRetry()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

extension String {
    func formattedDate() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard let date = dateFormatter.date(from: self) else { return nil }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .medium
        outputFormatter.timeStyle = .short
        return outputFormatter.string(from: date)
    }
}
