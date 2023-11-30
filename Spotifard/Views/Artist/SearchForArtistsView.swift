import SwiftUI
import SpotifyWebAPI
import Combine

struct SearchForArtistsView: View {

    @EnvironmentObject var spotify: Spotify
    
    @State private var isSearching = false
    
    @State var artists: [Artist] = []

    @State private var alert: AlertItem? = nil
    
    @State private var searchText = ""
    @State private var searchCancellable: AnyCancellable? = nil
    
    var body: some View {
        VStack {
            searchBar
                .padding([.top, .horizontal])
            Spacer()
            if artists.isEmpty {
                if isSearching {
                    HStack {
                        ProgressView()
                            .padding()
                        Text("Searching")
                            .font(.title)
                            .foregroundColor(.secondary)
                    }
                    
                }
                else {
                    Text("No Results")
                        .font(.title)
                        .foregroundColor(.secondary)
                }
            }
            else {
                List {
                    ForEach(artists, id: \.id) { artist in
                        NavigationLink {
                            ArtistView(artist: artist)
                        } label: {
                            ArtistCell(artist: artist)
                        }
                    }
                }
            }
            Spacer()
        }
        .listStyle(.plain)
        .navigationTitle("Search For Artists")
        .alert(item: $alert) { alert in
            Alert(title: alert.title, message: alert.message)
        }
    }
    
    /// A search bar. Essentially a textfield with a magnifying glass and an "x"
    /// button overlayed in front of it.
    var searchBar: some View {
        // `onCommit` is called when the user presses the return key.
        TextField("Search", text: $searchText, onCommit: search)
            .padding(.leading, 22)
            .overlay(
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    Spacer()
                    if !searchText.isEmpty {
                        // Clear the search text when the user taps the "x"
                        // button.
                        Button(action: {
                            self.searchText = ""
                            self.artists = []
                        }, label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        })
                    }
                }
            )
            .textContentType(.name)
            .padding(.vertical, 7)
            .padding(.horizontal, 7)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
    }
    
    /// Performs a search for artists based on `searchText`.
    func search() {

        self.artists = []

        if self.searchText.isEmpty { return }

        print("searching with query '\(self.searchText)'")
        self.isSearching = true
        
        self.searchCancellable = spotify.api.search(
            query: self.searchText, categories: [.artist]
        )
        .receive(on: RunLoop.main)
        .sink(
            receiveCompletion: { completion in
                self.isSearching = false
                if case .failure(let error) = completion {
                    self.alert = AlertItem(
                        title: "Couldn't Perform Search",
                        message: error.localizedDescription
                    )
                }
            },
            receiveValue: { searchResults in
                self.artists = searchResults.artists?.items ?? []
                print("received \(self.artists.count) artists")
            }
        )
    }
    
}

#Preview {
    let spotify = Spotify()
    let artists: [Artist] = [
        .crumb, .levitationRoom, .pinkFloyd, .radiohead, .skinshape, .theBeatles,
    ]

    return NavigationView {
        SearchForArtistsView(artists: artists)
    }
    .environmentObject(spotify)
}
