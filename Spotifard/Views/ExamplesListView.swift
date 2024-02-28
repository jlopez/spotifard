import SwiftUI
import SpotifyWebAPI

struct ExamplesListView: View {
    var body: some View {
        List {
            ForEach(Screen.allCases, id: \.self) { screen in
                NavigationLink(screen.title, value: screen)
            }
        }
        .navigationBarTitle("Spotifard")
        .listStyle(PlainListStyle())
    }
}

#Preview {
    return ScreenNavigationStack {
        ExamplesListView()
    }
    .environmentObject(Spotify())
}
