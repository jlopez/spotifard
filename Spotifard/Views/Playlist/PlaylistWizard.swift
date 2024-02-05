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
    let settings: PlaylistSettings

    @EnvironmentObject private var spotify: Spotify

    @State private var selectedPlaylistURI: String?
    @State private var relatedArtists: Set<Artist> = []
    @State private var relatedTracks: [Track] = []
    @State private var tracksAndFeatures: [TrackAndFeatures] = []
    @SceneStorage("trackFilter") private var filter: CodableWrapper<TrackFilter> = .init(value: .init())
    @State private var showPlaylistPicker: Bool = false
    @State private var showFilterSheet: Bool = false
    @State private var cancellables: Set<AnyCancellable> = []

    var filteredTracks: [TrackAndFeatures] {
        tracksAndFeatures.filter { filter.value.filter($0) }
    }

    var body: some View {
        List {
            ForEach(filteredTracks) { trackWithFeatures in
                TrackAndFeaturesCell(trackAndFeatures: trackWithFeatures)
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
                TrackFilterView(filter: $filter.value)
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
        let uris = filteredTracks.map { $0.track.uri! }
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
        guard level < settings.artistDepth else { return }
        try await withThrowingDiscardingTaskGroup { group in
            let chosenArtists = try await spotify.api.relatedArtists(artist.uri!, in: &cancellables)
                .reduce(into: []) { artists, batch in
                    artists.appendSorted(contentsOf: batch, by: Artist.popularityDescending)
                }
                .prefix(settings.artistCount)
            for chosenArtist in chosenArtists {
                guard relatedArtists.insert(chosenArtist).inserted else { continue }
                let tracks = try await spotify.api.artistTopTracks(chosenArtist.uri!, country: "US", cancellables: &cancellables)
                    .reduce(into: []) { tracks, batch in
                        tracks.appendSorted(contentsOf: batch, by: Track.popularityDescending)
                    }
                    .prefix(settings.trackCount)
                relatedTracks.appendSorted(contentsOf: tracks, by: Track.popularityDescending)
                group.addTask {
                    try await traverseRelatedArtists(for: chosenArtist, level: level + 1)
                }
            }
        }
        let uris = relatedTracks.map { $0.uri! }
        let features = try await spotify.api.tracksAudioFeatures(uris).values
            .reduce(into: [String: AudioFeatures]()) { dict, features in
                for feature in features {
                    guard let uri = feature?.uri else { continue }
                    dict[uri] = feature
                }
            }
        tracksAndFeatures = relatedTracks.compactMap { track in
            guard let features = features[track.uri!] else {
                print("Unable to get features for track \(track.name) (\(track.uri!))")
                return nil
            }
            return TrackAndFeatures(track: track, features: features)
        }
    }
}

struct TrackAndFeatures : Identifiable {
    var id: String { track.uri! }

    let track: Track
    let features: AudioFeatures
}

struct TrackAndFeaturesCell : View {
    let trackAndFeatures: TrackAndFeatures

    var body: some View {
        HStack {
            TrackCell(track: trackAndFeatures.track, audioFeatures: nil)
            Spacer()
            Text("\(trackAndFeatures.features.tempo, specifier: "%.0f") BPM")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct PlaylistSettings {
    var artistDepth = 1
    var artistCount = 10
    var trackCount = 3
}

#Preview {
    NavigationStack {
        PlaylistWizard(artist: Artist.crumb, settings: PlaylistSettings())
    }
    .environmentObject(Spotify())
}
