
import SwiftUI

struct MainTabsView: View {
    var body: some View {
        TabView {
            HomeView().tabItem {
                Label("Home", systemImage: "house")
            }
            
            CategoriesView().tabItem {
                Label("Categories", systemImage: "square.stack.3d.down.right.fill")
            }
            
            ProfileView().tabItem {
                Label("Profile", systemImage: "person")
            }
        }
    }
}
