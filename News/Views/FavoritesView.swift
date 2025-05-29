import SwiftUICore
import SwiftUI

struct FavoritesView: View {
    @ObservedObject var favoritesVM: FavoritesViewModel
    
    var body: some View {
        NavigationStack {
            if favoritesVM.favoriteArticles.isEmpty {
                VStack {
                    Image(systemName: "heart.slash")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                        .padding()
                    Text("No favourite articles yet")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            } else {
                List {
                    ForEach(favoritesVM.favoriteArticles) { article in
                        ArticleRow(article: article, favoritesVM: favoritesVM)
                    }
                    .onDelete { indices in
                        indices.forEach { index in
                            let article = favoritesVM.favoriteArticles[index]
                            favoritesVM.toggleFavorite(article)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Favourite News")
    }
}
