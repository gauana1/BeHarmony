import SwiftUI

struct NavBar: View {
    @Binding var selectedTab: Tab
    enum Tab {
        case home, messages, profile
    }
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Button(action: { selectedTab = .home }) {
                    Image(systemName: "house")
                        .padding(6)
                }
                Spacer()
                Button(action: { selectedTab = .messages }) {
                    Image(systemName: "message")
                        .padding(6)
                }
                Spacer()
                Button(action: { selectedTab = .profile }) {
                    Image(systemName: "person")
                        .padding(6)
                }
            }
            .font(.title)
            .foregroundColor(.blue)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 2)
        }
        .frame(maxWidth: .infinity)
    }
}



struct ContentView: View {
    @State private var selectedTab: NavBar.Tab = .home
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Text("Home")
                .font(.title)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                .tag(NavBar.Tab.home)
            
            Text("Messages")
                .font(.title)
                .tabItem {
                    Image(systemName: "message")
                    Text("Messages")
                }
                .tag(NavBar.Tab.messages)
            
            NavigationView { // Embed ProfileView within NavigationView
                            ProfileView(isLoggedIn: $isLoggedIn)
                        }
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
                .tag(NavBar.Tab.profile)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}

