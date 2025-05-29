import SwiftUI

@main
struct NewsApp: App {
    var body: some Scene {
        WindowGroup {
            AppTabView()
        }
    }
}

struct AppTabView: View {
    @StateObject private var favoritesVM = FavoritesViewModel()
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            CategoriesView()
                .tabItem {
                    Label("Categories", systemImage: "list.bullet")
                }
            
            FavoritesView(favoritesVM: favoritesVM)
                .tabItem{
                    Label("Favourites", systemImage: "heart")
                }
        }
        .environmentObject(favoritesVM)
    }
}
