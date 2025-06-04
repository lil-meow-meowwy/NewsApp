import SwiftUI
import CoreData

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
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isFavourite: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(article.title)
                    .font(.headline)
                
                Spacer()
                
                Button{
                    toggleFavourite()
                } label: {
                    Image(systemName: isFavourite ? "heart.fill" : "heart")
                        .foregroundColor(isFavourite ? .red : .gray)
                }
            }
        }
        .onAppear {
            checkFavouriteStatus()
        }
    }
    
    private func checkFavouriteStatus() {
        let fetchRequest: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "url == %@", article.url)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            isFavourite = results.first?.isFavourite ?? false
        } catch {
            print("Failed to check favourite status: \(error)")
        }
    }
    
    private func toggleFavourite() {
        let storageService = NewsStorageService(context: viewContext)
        storageService.toggleFavourite(article: article)
        isFavourite.toggle()
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
