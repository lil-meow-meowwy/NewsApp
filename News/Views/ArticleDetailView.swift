import SwiftUI
import CoreData

struct ArticleDetailView: View {
    let article: Article
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isFavourite: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Зображення новини
                if let imageUrl = article.urlToImage, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(height: 250)
                    .clipped()
                    .cornerRadius(10)
                }
                
                // Заголовок
                Text(article.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Джерело та дата
                HStack {
                    Text(article.source.name)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    if let date = article.publishedAt.formattedDate() {
                        Text(date)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
                
                // Автор
                if let author = article.author {
                    Text("Author: \(author)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Опис
                if let description = article.description {
                    Text(description)
                        .font(.body)
                        .padding(.vertical, 8)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Контент
                if let content = article.content {
                    Text(content)
                        .font(.body)
                        .padding(.vertical, 8)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Посилання
                if let url = URL(string: article.url) {
                    Link("Read the original", destination: url)
                        .font(.headline)
                        .padding(.top, 8)
                }
            }
            .padding()
        }
        .navigationTitle(article.source.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
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
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            isFavourite = results.first?.isFavourite ?? false
        } catch {
            print("Failed to check favourite status: \(error)")
        }
    }
    
    private func toggleFavourite() {
        let storageService = NewsStorageService(context: viewContext)
        
        storageService.addToFavourites(article: article)
        
        isFavourite.toggle()
    }
}
