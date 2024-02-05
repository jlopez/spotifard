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
    @State private var audioFeaturesMap = [String: AudioFeatures]()
    @EnvironmentObject private var spotify: Spotify

    var sortedTracks: [Track] {
        tracks.sorted { a, b in
            audioFeaturesForTrack(a)?.tempo ?? 0 < audioFeaturesForTrack(b)?.tempo ?? 0
        }
    }

    var body: some View {
        VStack {
            if tracks.isEmpty {
                Text("Fetching tracks...")
            } else {
                List(sortedTracks) { track in
                    TrackCell(track: track, audioFeatures: audioFeaturesForTrack(track))
                }
            }
        }
        .navigationTitle(playlist.name)
        .task(fetchTracks)
    }

    @Sendable
    func fetchTracks() async {
        print("Fetching tracks")
        do {
            var fetchedTracks = [Track]()
            for try await pagingObject in spotify.api.playlistTracks(playlist)
                .extendPages(spotify.api)
                .values {
                fetchedTracks.append(contentsOf: pagingObject.items.compactMap { $0.item })
            }
            let uris = fetchedTracks.compactMap(\.uri)
            var fetchedFeatures = [String: AudioFeatures]()
            for try await features in spotify.api.tracksAudioFeatures(uris)
                .values {
                for feature in features.compactMap({ $0 }) {
                    fetchedFeatures[feature.uri] = feature
                }
            }
            tracks = fetchedTracks
            audioFeaturesMap = fetchedFeatures
        } catch {
            print("Error fetching tracks: \(error)")
        }
    }

    func audioFeaturesForTrack(_ track: Track) -> AudioFeatures? {
        guard let uri = track.uri else { return nil }
        return audioFeaturesMap[uri]
    }
}

#Preview {
    NavigationStack {
        PlaylistTracksView(playlist: .lucyInTheSkyWithDiamonds)
            .environmentObject(Spotify())
    }
}
