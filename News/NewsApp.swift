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
        }
    }
}
