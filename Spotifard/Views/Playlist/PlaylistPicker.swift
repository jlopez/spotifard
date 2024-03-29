//
//  PlaylistPicker.swift
//  Spotifard
//
//  Created by Jesus Lopez on 11/28/23.
//

import SwiftUI
import Combine
import SpotifyWebAPI

struct PlaylistPicker: View {
    @Binding var playlistURI: String?
    let newPlaylistDescription = "Created by Spotifard"
    @EnvironmentObject private var spotify: Spotify
    @Environment(\.dismiss) private var dismiss
    @State private var searchTerm: String = ""
    @State private var playlists: [Playlist<PlaylistItemsReference>] = []
    @State private var cancellables: Set<AnyCancellable> = []

    var filteredPlaylists: [Playlist<PlaylistItemsReference>] {
        guard !searchTerm.isEmpty else { return playlists }
        let pattern = searchTerm.localizedLowercase
        return playlists.filter { $0.name.localizedLowercase.contains(pattern)}
    }

    func mayCreatePlaylist() -> Bool {
        !searchTerm.isEmpty && playlists
            .filter { $0.name == searchTerm }
            .isEmpty
    }

    var body: some View {
        VStack {
            SearchBar(searchTerm: $searchTerm)
            List {
                if mayCreatePlaylist() {
                    Button("Create playlist \"\(searchTerm)\"") {
                        Task {
                            let playlist = try await createPlaylist(searchTerm)
                            selectPlaylist(playlist)
                        }
                    }
                }
                ForEach(filteredPlaylists) { playlist in
                    Button {
                        selectPlaylist(playlist)
                    } label: {
                        PlaylistCell(playlist: playlist)
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .padding(4)
                }
            }
            .listRowSpacing(0)
        }
        .listStyle(.plain)
        .navigationTitle("Add to playlist")
        .toolbar { Button { dismiss() } label: { Text("Cancel") } }
        .onAppear(perform: fetchPlaylists)
        .onAppear { playlistURI = nil }
    }

    func fetchPlaylists() {
        // self.isLoadingPlaylists = true
        var clearList = true
        spotify.api.currentUserPlaylists(limit: 50)
            // Gets all pages of playlists.
            .extendPages(spotify.api)
            // Gets all pages of playlists.
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    // self.isLoadingPlaylists = false
//                    switch completion {
//                        case .finished:
//                            self.couldntLoadPlaylists = false
//                        case .failure(let error):
//                            self.couldntLoadPlaylists = true
//                            self.alert = AlertItem(
//                                title: "Couldn't Retrieve Playlists",
//                                message: error.localizedDescription
//                            )
//                    }
                },
                // We will receive a value for each page of playlists. You could
                // use Combine's `collect()` operator to wait until all of the
                // pages have been retrieved.
                receiveValue: { playlistPage in
                    if clearList {
                        self.playlists = []
                        clearList = false
                    }
                    for playlist in playlistPage.items {
                        self.playlists.insertSorted(playlist, by: nameAscending)
                    }
                }
            )
            .store(in: &cancellables)

    }

    func nameAscending<T>(a: Playlist<T>, b: Playlist<T>) -> Bool {
        a.name < b.name
    }

    func createPlaylist(_ name: String) async throws -> Playlist<PlaylistItems> {
        guard let me = spotify.currentUser else { throw PlaylistCreationError.noCurrentUser }
        return try await withCheckedThrowingContinuation({ continuation in
            let details = PlaylistDetails(name: name, description: newPlaylistDescription)
            var createdPlaylist: Playlist<PlaylistItems>?
            spotify.api.createPlaylist(for: me, details)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished where createdPlaylist != nil:
                        continuation.resume(returning: createdPlaylist!)
                    case .finished:
                        continuation.resume(throwing: PlaylistCreationError.noPlaylistEmitted)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }, receiveValue: { playlist in
                    guard createdPlaylist == nil else { return }
                    createdPlaylist = playlist
                })
                .store(in: &cancellables)
        })
    }

    func selectPlaylist<T>(_ playlist: Playlist<T>) {
        playlistURI = playlist.uri
        dismiss()
    }
}

enum PlaylistCreationError : Error {
    case noCurrentUser
    case noPlaylistEmitted
}

#Preview("Normal") {
    return NavigationStack {
        PlaylistPicker(playlistURI: .constant(nil))
    }
    .environmentObject(Spotify())
}

#Preview("Sheet") {
    struct Container: View {
        @State var playlistURI: String? = nil
        @State var show = true
        var body: some View {
            NavigationStack {
                Button { show.toggle() } label: { Text("Show sheet") }
                    .navigationTitle("Related Songs")
                    .sheet(isPresented: $show, onDismiss: {
                        print("PlaylistURI \(playlistURI ?? "None")")
                    }) {
                        NavigationStack { PlaylistPicker(playlistURI: $playlistURI) }
                    }
            }
        }
    }
    return Container()
        .environmentObject(Spotify())
}
