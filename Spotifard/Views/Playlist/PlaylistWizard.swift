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

    @State private var relatedArtists: Set<Artist> = []
    @State private var relatedTracks: [Track] = []
    @State private var addToPlaylistPopover: Bool = false
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
        .navigationBarItems(trailing:
            Button {
                addToPlaylistPopover.toggle()
            } label: {
                Image(systemName: "text.badge.plus")
                    .sheet(isPresented: $addToPlaylistPopover) {
                        PlaylistSelectionView { playlist in
                            let uris = relatedTracks.map { $0.uri! }
                            spotify.api.addToPlaylist(playlist, uris: uris)
                                .receive(on: RunLoop.main)
                                .sink { completion in
                                } receiveValue: { snapshot in
                                    print("Snapshot: \(snapshot)")
                                }
                                .store(in: &cancellables)
                            print("Playlist: \(playlist)")
                        }
                    }
            }
        )
        .task {
            do {
                try await traverseRelatedArtists(for: artist, level: 0)
            } catch {
                print(error)
            }
        }
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
                print("\(level). \(chosenArtist.name)")
                let tracks = try await spotify.api.artistTopTracks(chosenArtist.uri!, country: "US", cancellables: &cancellables)
                    .reduce(into: []) { tracks, batch in
                        tracks.appendSorted(contentsOf: batch, by: Track.popularityDescending)
                    }
                    .prefix(trackCount)
                relatedTracks.appendSorted(contentsOf: tracks, by: Track.popularityDescending)
                group.addTask {
                    try await traverseRelatedArtists(for: chosenArtist, level: level + 1)
                }
                group.addTask {
                    for track in tracks {
                        print("\(level). \(chosenArtist.name) \(track.name)")
                    }
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
