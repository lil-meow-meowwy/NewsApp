import SwiftUICore
import SwiftUI

struct CategoriesView: View {
    @StateObject private var viewModel = NewsViewModel()
    @State private var selectedCategory: Category?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                    ForEach(Category.allCases) { category in
                        CategoryCard(
                            category: category,
                            isSelected: selectedCategory == category
                        )
                        .onTapGesture {
                            selectedCategory = category
                            viewModel.loadArticles(category: category, isRefreshing: true)
                        }
                    }
                }
                .padding()
                
                if viewModel.isLoading {
                    ProgressView()
                } else if let error = viewModel.error {
                    ErrorView(error: error) {
                        viewModel.loadArticles(category: selectedCategory)
                    }
                } else if viewModel.articles.isEmpty {
                    Text(selectedCategory == nil ?
                         "Choose a category" :
                         "There are no articles in this category")
                    .foregroundColor(.gray)
                } else {
                    LazyVStack {
                        ForEach(viewModel.articles) { article in
                            ArticleRow(article: article)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Categories")
            .refreshable {
                viewModel.loadArticles(category: selectedCategory, isRefreshing: true)
            }
        }
    }
}

struct CategoryCard: View {
    let category: Category
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: iconForCategory(category))
                .font(.system(size: 20)) // Зменшений розмір іконки
                .foregroundColor(isSelected ? .blue : .primary)
            
            Text(category.displayName)
                .font(.system(size: 12)) // Зменшений розмір тексту
                .foregroundColor(isSelected ? .blue : .primary)
                .multilineTextAlignment(.center)
        }
        .frame(width: 80, height: 80) // Фіксований розмір картки
        .background(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1)
        )
        .padding(4)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("\(category.rawValue)_category_button")
        .accessibilityLabel(category.displayName)
        .accessibilityAddTraits(.isButton)
    }
    
    private func iconForCategory(_ category: Category) -> String {
        switch category {
        case .business: return "dollarsign.circle"
        case .entertainment: return "film"
        case .general: return "newspaper"
        case .health: return "heart"
        case .science: return "atom"
        case .sports: return "sportscourt"
        case .technology: return "laptopcomputer"
        }
    }
}
