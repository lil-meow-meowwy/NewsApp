import SwiftUICore
import SwiftUI

struct ArticleDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isFavorite: Bool
    let article: Article
    
    @ObservedObject var favoritesVM: FavoritesViewModel
    
    init(article: Article, favoritesVM: FavoritesViewModel) {
        self.article = article
        self._isFavorite = State(initialValue: favoritesVM.isFavorite(article))
        self.favoritesVM = favoritesVM
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Зображення новини
                if let urlString = article.urlToImage, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(height: 250)
                    .clipped()
                }
                
                // Заголовок
                Text(article.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
                
                // Автор та дата
                HStack {
                    if let author = article.author {
                        Text(author)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if let date = article.publishedAt.formattedDate() {
                        Text(date)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                
                // Основний текст статті
                VStack(alignment: .leading, spacing: 12) {
                    if let description = article.description {
                        Text(description)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    if let content = article.content {
                        Text(content)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.horizontal)
        
                // Посилання
                if let url = URL(string: article.url) {
                    Link("Read Original Article", destination: url)
                        .font(.headline)
                        .padding()
                }
            }
        }
        .navigationTitle(article.source.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: toggleFavorite) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(isFavorite ? .red : .primary)
                }
            }
        }
    }
    
    private func toggleFavorite() {
        isFavorite.toggle()
        let updatedArticle = favoritesVM.toggleFavorite(article)
        print("Article favorite status: \(updatedArticle.isFavorite)")
    }
}
