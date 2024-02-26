//
//  PlaylistTracksView.swift
//  Spotifard
//
//  Created by Jesus Lopez on 2/4/24.
//

import SwiftUI
import SpotifyWebAPI

struct PlaylistTracksView: View {
    let playlist: Playlist<PlaylistItemsReference>
    @State private var tracks = [Track]()
    @EnvironmentObject private var spotify: Spotify

    var body: some View {
        VStack {
            if tracks.isEmpty {
                Text("Fetching tracks...")
            } else {
                TracksView(tracks: tracks, contextUri: playlist.uri)
            }
        }
        .navigationTitle(playlist.name)
        .task(fetchTracks)
    }

    @Sendable
    func fetchTracks() async {
        do {
            var fetchedTracks = [Track]()
            for try await pagingObject in spotify.api.playlistTracks(playlist)
                .extendPages(spotify.api)
                .values {
                fetchedTracks.append(contentsOf: pagingObject.items.compactMap { $0.item })
            }
            tracks = fetchedTracks
        } catch {
            print("Error fetching tracks: \(error)")
        }
    }
}

#Preview {
    NavigationStack {
        PlaylistTracksView(playlist: .lucyInTheSkyWithDiamonds)
            .environmentObject(Spotify())
    }
}
