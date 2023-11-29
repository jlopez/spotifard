import SwiftUI

struct ExamplesListView: View {

    var body: some View {
        List {

            NavigationLink("Playlists") {
                PlaylistsListView()
            }
            NavigationLink("Saved Albums") {
                SavedAlbumsGridView()
            }
            NavigationLink("Search For Tracks") {
                SearchForTracksView()
            }
            NavigationLink("Search For Artists") {
                SearchForArtistsView()
            }
            NavigationLink("Recently Played Tracks") {
                RecentlyPlayedView()
            }
            NavigationLink("Debug Menu") {
                DebugMenuView()
            }

            // This is the location where you can add your own views to test out
            // your application. Each view receives an instance of `Spotify`
            // from the environment.

        }
        .navigationBarTitle("Spotifard")
        .listStyle(PlainListStyle())

    }
}

#Preview {
    let spotify = Spotify()
    spotify.isAuthorized = true

    return NavigationView {
        ExamplesListView()
            .environmentObject(spotify)
    }
}
