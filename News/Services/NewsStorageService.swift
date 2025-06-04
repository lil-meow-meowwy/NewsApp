import CoreData

class NewsStorageService {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }
    
    func saveArticles(_ articles: [Article], for category: String? = nil, query: String? = nil) {
        deleteOldArticles()
        
        for article in articles {
            let articleEntity = NSEntityDescription.insertNewObject(
                forEntityName: "ArticleEntity",
                into: context
            ) as! ArticleEntity
            
            articleEntity.id = UUID()
            articleEntity.title = article.title
            articleEntity.source = article.source.name
            articleEntity.author = article.author
            articleEntity.desc = article.description
            articleEntity.url = article.url
            articleEntity.urlToImage = article.urlToImage
            articleEntity.publishedAt = article.publishedAt
            articleEntity.content = article.content
            articleEntity.category = category
            articleEntity.searchQuery = query
            articleEntity.savedAt = Date()
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to save articles: \(error)")
        }
    }
    
    func fetchArticles(for category: String? = nil, query: String? = nil, page: Int, pageSize: Int) -> [Article] {
        let fetchRequest: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
        fetchRequest.fetchOffset = (page - 1) * pageSize
        fetchRequest.fetchLimit = pageSize
        
        var predicates = [NSPredicate]()
        
        if let category = category {
            predicates.append(NSPredicate(format: "category == %@", category))
        }
        
        if let query = query, !query.isEmpty {
            predicates.append(NSPredicate(format: "title CONTAINS[cd] %@ OR desc CONTAINS[cd] %@", query, query))
        }
        
        if !predicates.isEmpty {
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "publishedAt", ascending: false)]
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.map { Article(
                source: Source(id: nil, name: $0.source ?? "Unknown"),
                author: $0.author,
                title: $0.title ?? "",
                description: $0.desc,
                url: $0.url ?? "",
                urlToImage: $0.urlToImage,
                publishedAt: $0.publishedAt ?? "",
                content: $0.content
            )}
        } catch {
            print("Failed to fetch articles: \(error)")
            return []
        }
    }
    
    private func deleteOldArticles() {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let fetchRequest: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "savedAt < %@", cutoffDate as CVarArg)
        
        do {
            let oldArticles = try context.fetch(fetchRequest)
            for article in oldArticles {
                context.delete(article)
            }
            try context.save()
        } catch {
            print("Failed to delete old articles: \(error)")
        }
    }
    
    func addToFavourites(article: Article) {
        let fetchRequest: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "url == %@", article.url)
        
        do {
            let results = try context.fetch(fetchRequest)
            
            if let existingArticle = results.first {
                existingArticle.isFavourite.toggle()
            } else {
                let newArticle = ArticleEntity(context: context)
                newArticle.id = UUID()
                newArticle.title = article.title
                newArticle.source = article.source.name
                newArticle.author = article.author
                newArticle.desc = article.description
                newArticle.url = article.url
                newArticle.urlToImage = article.urlToImage
                newArticle.publishedAt = article.publishedAt
                newArticle.content = article.content
                newArticle.isFavourite = true
                newArticle.savedAt = Date()
            }
            
            try context.save()
        } catch {
            print("Failed to toggle favourite: \(error)")
        }
    }

    func removeFromFavourites(article: Article) {
        let request: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
        request.predicate = NSPredicate(format: "url == %@", article.url)
        
        do {
            if let articleEntity = try context.fetch(request).first {
                articleEntity.isFavourite = false
                try context.save()
            }
        } catch {
            print("Failed to remove from favourites: \(error)")
        }
    }
    
    func getFavouriteArticles() -> [Article] {
        let fetchRequest: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isFavourite == YES")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "savedAt", ascending: false)]
        
        fetchRequest.propertiesToFetch = ["url", "title", "source", "author", "desc", "urlToImage", "publishedAt", "content"]
        fetchRequest.returnsDistinctResults = true
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.compactMap { entity in
                guard let url = entity.url else { return nil }
                return Article(
                    source: Source(id: nil, name: entity.source ?? "Unknown"),
                    author: entity.author,
                    title: entity.title ?? "",
                    description: entity.desc,
                    url: url,
                    urlToImage: entity.urlToImage,
                    publishedAt: entity.publishedAt ?? "",
                    content: entity.content
                )
            }
        } catch {
            print("Failed to fetch favourites: \(error)")
            return []
        }
    }
}
