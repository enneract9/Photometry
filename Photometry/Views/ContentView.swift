import SwiftUI
import SwiftData

struct ContentView: View {
    
    let storage: ModelStorage
    @State private var selectedTab: Tab = .ar
    
    init(storage: ModelStorage = .default) {
        self.storage = storage
    }

    var body: some View {
        TabView {
            NavigationView {
                StorageView(storage: storage)
            }
            .tag(Tab.ar)
        }
        .overlay(alignment: .bottom) {
            TabBar(selectedTab: $selectedTab)
        }
    }
}

#Preview {
    ContentView(storage: .mock)
}
