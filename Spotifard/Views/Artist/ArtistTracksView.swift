//
//  ArtistTracksView.swift
//  Spotifard
//
//  Created by Jesus Lopez on 2/11/24.
//

import SwiftUI
import SpotifyWebAPI

struct ArtistTracksView: View {
    let artist: Artist
    @State private var tracks = [Track]()
    @EnvironmentObject private var spotify: Spotify

    var body: some View {
        VStack {
            if tracks.isEmpty {
                Text("Fetching tracks...")
            } else {
                TracksView(tracks: tracks, caption: .album, contextUri: artist.uri)
            }
        }
        .navigationTitle(artist.name)
        .task(fetchTracks)
    }

    @Sendable
    func fetchTracks() async {
        do {
            var albums = [Album]()
            for try await pagingObject in spotify.api.artistAlbums(artist.uri!, groups: [.album])
                .extendPages(spotify.api)
                .values {
                albums.append(contentsOf: pagingObject.items.compactMap { $0 })
            }
            var fetchedTracks = [Track]()
            for album in albums {
                for try await pagingObject in spotify.api.albumTracks(album.uri!)
                    .extendPages(spotify.api)
                    .values {
                    fetchedTracks.append(contentsOf: pagingObject.items.compactMap { $0 })
                }
            }
            tracks = fetchedTracks
        } catch {
            print("Error fetching tracks: \(error)")
        }
    }
}

#Preview {
    ArtistTracksView(artist: .crumb)
        .environmentObject(Spotify())
}
