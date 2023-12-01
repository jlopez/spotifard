//
//  PlaylistWizard.swift
//  Spotifard
//
//  Created by Jesus Lopez on 11/29/23.
//

import SwiftUI
import Combine
import SpotifyWebAPI

struct PlaylistWizard: View {
    let artist: Artist

    @EnvironmentObject private var spotify: Spotify

    @State private var selectedPlaylistURI: String?
    @State private var relatedArtists: Set<Artist> = []
    @State private var relatedTracks: [Track] = []
    @SceneStorage("trackFilter") private var filter = TrackFilter()
    @State private var showPlaylistPicker: Bool = false
    @State private var showFilterSheet: Bool = false
    @State private var cancellables: Set<AnyCancellable> = []
    private let artistDepth = 2
    private let artistCount = 3
    private let trackCount = 3

    var body: some View {
        List {
            ForEach(relatedTracks) { track in
                TrackCell(track: track)
            }
        }
        .navigationTitle("Related Songs")
        .navigationBarItems(trailing: Button {
            showPlaylistPicker.toggle()
        } label: {
            Image(systemName: "plus")
        })
        .navigationBarItems(trailing: Button {
            showFilterSheet.toggle()
        } label: {
            Image(systemName: "slider.horizontal.3")
        })
        .sheet(isPresented: $showFilterSheet) {
            NavigationStack {
                TrackFilterView(filter: $filter)
            }
            .presentationDetents([ .medium, .large ])
        }
        .sheet(isPresented: $showPlaylistPicker, onDismiss: addTracksToPlaylist) {
            NavigationStack {
                PlaylistPicker(playlistURI: $selectedPlaylistURI)
            }
        }
        .task {
            do {
                try await traverseRelatedArtists(for: artist, level: 0)
            } catch {
                print(error)
            }
        }
    }

    func addTracksToPlaylist() {
        guard let playlistURI = selectedPlaylistURI else { return }
        let uris = relatedTracks.map { $0.uri! }
        spotify.api.addToPlaylist(playlistURI, uris: uris)
            .receive(on: RunLoop.main)
            .sink { completion in
            } receiveValue: { snapshot in
                print("Playlist snapshot: \(snapshot)")
            }
            .store(in: &cancellables)
        print("Added tracks to playlist: \(playlistURI)")
    }

    func traverseRelatedArtists(for artist: Artist, level: Int) async throws {
        guard level < artistDepth else { return }
        try await withThrowingDiscardingTaskGroup { group in
            let chosenArtists = try await spotify.api.relatedArtists(artist.uri!, in: &cancellables)
                .reduce(into: []) { artists, batch in
                    artists.appendSorted(contentsOf: batch, by: Artist.popularityDescending)
                }
                .prefix(artistCount)
            for chosenArtist in chosenArtists {
                guard relatedArtists.insert(chosenArtist).inserted else { continue }
                let tracks = try await spotify.api.artistTopTracks(chosenArtist.uri!, country: "US", cancellables: &cancellables)
                    .reduce(into: []) { tracks, batch in
                        tracks.appendSorted(contentsOf: batch, by: Track.popularityDescending)
                    }
                    .prefix(trackCount)
                relatedTracks.appendSorted(contentsOf: tracks, by: Track.popularityDescending)
                group.addTask {
                    try await traverseRelatedArtists(for: chosenArtist, level: level + 1)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        PlaylistWizard(artist: Artist.crumb)
    }
    .environmentObject(Spotify())
}
