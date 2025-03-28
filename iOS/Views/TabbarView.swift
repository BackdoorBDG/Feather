import SwiftUI

struct TabbarView: View {
    @State private var selectedTab: Tab = Tab(rawValue: UserDefaults.standard.string(forKey: "selectedTab") ?? "home") ?? .home
    
    enum Tab: String {
        case home
        case sources
        case library
        case settings
        case bdgHub // Add new tab case
    }

    // Initialize with notification observer for tab changes
    init() {
        // Register for tab change notifications from the AI assistant
        NotificationCenter.default.addObserver(forName: .changeTab, object: nil, queue: .main) { [self] notification in // Updated line
            if let newTab = notification.userInfo?["tab"] as? String,
               let tab = Tab(rawValue: newTab) {
                self.selectedTab = tab // Updated line
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            tab(for: .home)
            tab(for: .sources)
            tab(for: .library)
            tab(for: .settings)
            tab(for: .bdgHub) // Add new tab
        }
        .onChange(of: selectedTab) { newTab in
            // Save the selected tab to UserDefaults
            UserDefaults.standard.set(newTab.rawValue, forKey: "selectedTab")
            // Trigger animation for tab change
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.5)) {
                // No explicit action needed here; the animation will apply to the tab transition
            }
        }
    }

    @ViewBuilder
    func tab(for tab: Tab) -> some View {
        switch tab {
        case .home:
            NavigationViewController(HomeViewController.self, title: String.localized("TAB_HOME"))
                .edgesIgnoringSafeArea(.all)
                .tabItem { 
                    Label(String.localized("TAB_HOME"), systemImage: "house.fill") 
                }
                .tag(Tab.home)
        case .sources:
            NavigationViewController(SourcesViewController.self, title: String.localized("TAB_SOURCES"))
                .edgesIgnoringSafeArea(.all)
                .tabItem {
                    Label(
                        String.localized("TAB_SOURCES"),
                        systemImage: {
                            if #available(iOS 16.0, *) {
                                return "globe.desk.fill"
                            } else {
                                return "books.vertical.fill"
                            }
                        }()
                    )
                }
                .tag(Tab.sources)
        case .library:
            NavigationViewController(LibraryViewController.self, title: String.localized("TAB_LIBRARY"))
                .edgesIgnoringSafeArea(.all)
                .tabItem { Label(String.localized("TAB_LIBRARY"), systemImage: "square.grid.2x2.fill") }
                .tag(Tab.library)
        case .settings:
            NavigationViewController(SettingsViewController.self, title: String.localized("TAB_SETTINGS"))
                .edgesIgnoringSafeArea(.all)
                .tabItem { Label(String.localized("TAB_SETTINGS"), systemImage: "gearshape.2.fill") }
                .tag(Tab.settings)
        case .bdgHub: // New tab case
            NavigationViewController(WebViewController.self, title: "BDG HUB") // Assuming no localization for now
                .edgesIgnoringSafeArea(.all)
                .tabItem { Label("BDG HUB", systemImage: "star.fill") } // Choose an appropriate SF Symbol
                .tag(Tab.bdgHub)
        }
    }
}

struct NavigationViewController<Content: UIViewController>: UIViewControllerRepresentable {
    let content: Content.Type
    let title: String

    init(_ content: Content.Type, title: String) {
        self.content = content
        self.title = title
    }

    func makeUIViewController(context: Context) -> UINavigationController {
        let viewController = content.init()
        viewController.navigationItem.title = title
        return UINavigationController(rootViewController: viewController)
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}