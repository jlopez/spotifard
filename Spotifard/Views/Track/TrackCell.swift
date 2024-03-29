//
//  TrackCell.swift
//  Spotifard
//
//  Created by Jesus Lopez on 11/29/23.
//

import SwiftUI
import Combine
import SpotifyWebAPI

struct TrackCell: View {
    let track: Track
    let caption: Caption
    let contextUri: SpotifyURIConvertible?
    let audioFeatures: AudioFeatures?

    enum Caption {
        case artist
        case album
    }

    @EnvironmentObject private var spotify: Spotify
    @State private var playRequestCancellable: AnyCancellable? = nil

    private var captionText: String {
        switch caption {
            case .artist:
                return track.artists?.first?.name ?? ""
            case .album:
                return track.album?.name ?? ""
        }
    }

    init(track: Track, caption: Caption = .artist, contextUri: SpotifyURIConvertible? = nil, audioFeatures: AudioFeatures? = nil) {
        self.track = track
        self.caption = caption
        self.contextUri = contextUri
        self.audioFeatures = audioFeatures
    }

    var body: some View {
        HStack {
            SpotifyAsyncImage(images: track.album?.images)
                .frame(width: 50, height: 50)
            VStack {
                HStack {
                    Text(track.name)
                        .truncationMode(.tail)
                        .lineLimit(1)
                    Spacer()
                    Text("\(track.popularity?.description ?? "")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text(captionText)
                    Spacer()
                    if let audioFeatures = audioFeatures {
                        Text("\(Int(audioFeatures.tempo)) BPM")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .onTapGesture {
            playTrack()
        }
    }

    func playTrack() {

        let playbackRequest: PlaybackRequest

        if let contextUri = contextUri ?? track.album?.uri {
            // Play the track in the context of its album. Always prefer
            // providing a context; otherwise, the back and forwards buttons may
            // not work.
            playbackRequest = PlaybackRequest(
                context: .contextURI(contextUri),
                offset: .uri(track.uri!)
            )
        }
        else {
            playbackRequest = PlaybackRequest(track.uri!)
        }

        // By using a single cancellable rather than a collection of
        // cancellables, the previous request always gets cancelled when a new
        // request to play a track is made.
        self.playRequestCancellable =
            self.spotify.api.getAvailableDeviceThenPlay(playbackRequest)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                })

    }
}

#Preview {
    let tracks: [Track] = [
        .because, .comeTogether, .faces, .illWind, .odeToViceroy,
        .reckoner, .theEnd, .time
    ]
    return List(tracks) { track in
        TrackCell(track: track)
    }
    .environmentObject(Spotify())
}
