import SwiftUI
import CoreData

struct FavouritesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var favouriteArticles: [Article] = []
    
    var body: some View {
        NavigationStack {
            Group {
                if favouriteArticles.isEmpty {
                    emptyStateView
                } else {
                    List(favouriteArticles) { article in
                        NavigationLink(destination: ArticleDetailView(article: article)) {
                            ArticleRow(article: article)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Favourites")
            .refreshable {
                loadFavourites()
            }
        }
        .onAppear {
            loadFavourites()
        }
    }
    
    private var emptyStateView: some View {
        VStack {
            Image(systemName: "heart.slash")
                .font(.system(size: 50))
                .foregroundColor(.gray)
                .padding()
            Text("No favourite news.")
                .font(.title2)
                .foregroundColor(.gray)
        }
    }
    
    private func loadFavourites() {
        let storageService = NewsStorageService(context: viewContext)
        
        favouriteArticles = storageService.getFavouriteArticles()
    }
}
