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
}
