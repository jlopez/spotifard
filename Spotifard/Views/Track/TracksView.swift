//
//  TracksView.swift
//  Spotifard
//
//  Created by Jesus Lopez on 2/11/24.
//

import SwiftUI
import SpotifyWebAPI

struct TracksView: View {
    let tracks: [Track]
    let caption: TrackCell.Caption
    let contextUri: SpotifyURIConvertible?
    @State private var audioFeaturesMap = [String: AudioFeatures]()
    @EnvironmentObject private var spotify: Spotify

    init(tracks: [Track], caption: TrackCell.Caption = .artist, contextUri: SpotifyURIConvertible? = nil) {
        self.tracks = tracks
        self.caption = caption
        self.contextUri = contextUri
    }

    private var sortedTracks: [Track] {
        tracks.sorted { a, b in
            audioFeaturesForTrack(a)?.normalizedTempo ?? 0 < audioFeaturesForTrack(b)?.normalizedTempo ?? 0
        }
    }

    var body: some View {
        List(sortedTracks) { track in
            TrackCell(track: track, caption: caption, contextUri: contextUri, audioFeatures: audioFeaturesForTrack(track))
        }
        .task(fetchAudioFeatures)
    }

    @Sendable
    func fetchAudioFeatures() async {
        print("Fetching audio features")
        do {
            let uris = tracks.compactMap(\.uri)
            var fetchedFeatures = [String: AudioFeatures]()
            // Split the uri list into groups of 50 and fetch features
            for urisChunk in uris.chunked(size: 50) {
                for try await features in spotify.api.tracksAudioFeatures(urisChunk)
                    .values {
                    for feature in features.compactMap({ $0 }) {
                        fetchedFeatures[feature.uri] = feature
                    }
                }
            }
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
    let tracks: [Track] = [
        .because, .comeTogether, .faces, .illWind,
        .odeToViceroy, .reckoner, .theEnd
    ]
    return TracksView(tracks: tracks, contextUri: nil)
        .environmentObject(Spotify())
}
