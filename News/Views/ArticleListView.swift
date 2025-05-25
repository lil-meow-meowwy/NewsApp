import SwiftUI

struct ArticleListView: View {
    let articles: [Article]
    let isLoading: Bool
    let error: Error?
    let onRefresh: () -> Void
    let onLoadMore: () -> Void
    
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
                    ArticleRow(article: article)
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
    
    init(article: Article){
        self.article = article
        print("Displaying article: \(article.title)")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let urlToImage = article.urlToImage, let url = URL(string: urlToImage) {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(height: 200)
                .clipped()
                .cornerRadius(8)
            }
            
            Text(article.title)
                .font(.headline)
                .accessibilityIdentifier("article_title")
            
            if let description = article.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack {
                Text(article.source.name)
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Spacer()
                
                if let date = article.publishedAt.formattedDate() {
                    Text(date)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .padding(.vertical, 8)
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
