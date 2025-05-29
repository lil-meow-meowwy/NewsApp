import Foundation

class FavoritesViewModel: ObservableObject {
    @Published var favoriteArticles: [Article] = []
    
    func toggleFavorite(_ article: Article) -> Article {
        var updatedArticle = article
        updatedArticle.isFavorite.toggle()
        
        if updatedArticle.isFavorite {
            favoriteArticles.append(updatedArticle)
        } else {
            favoriteArticles.removeAll { $0.id == article.id }
        }
        
        return updatedArticle
    }
    
    func isFavorite(_ article: Article) -> Bool {
        favoriteArticles.contains { $0.id == article.id }
    }
}
