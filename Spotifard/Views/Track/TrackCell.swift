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

    @EnvironmentObject private var spotify: Spotify
    @State private var playRequestCancellable: AnyCancellable? = nil

    var body: some View {
        HStack {
            SpotifyAsyncImage(images: track.album!.images)
                .frame(width: 50, height: 50)
            VStack(alignment: .leading) {
                Text(track.name)
                Text(track.artists?.first?.name ?? "")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text("\(track.popularity?.description ?? "")")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .onTapGesture {
            playTrack()
        }
    }

    func playTrack() {

        let playbackRequest: PlaybackRequest

        if let albumURI = track.album?.uri {
            // Play the track in the context of its album. Always prefer
            // providing a context; otherwise, the back and forwards buttons may
            // not work.
            playbackRequest = PlaybackRequest(
                context: .contextURI(albumURI),
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
