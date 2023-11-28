import SwiftUI

struct ExamplesListView: View {

    var body: some View {
        List {

            NavigationLink(
                "Playlists", destination: PlaylistsListView()
            )
            NavigationLink(
                "Saved Albums", destination: SavedAlbumsGridView()
            )
            NavigationLink(
                "Search For Tracks", destination: SearchForTracksView()
            )
            NavigationLink(
                "Recently Played Tracks", destination: RecentlyPlayedView()
            )
            NavigationLink(
                "Debug Menu", destination: DebugMenuView()
            )

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
