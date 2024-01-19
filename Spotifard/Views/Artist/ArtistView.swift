//
//  ArtistView.swift
//  Spotifard
//
//  Created by Jesus Lopez on 11/28/23.
//

import SwiftUI
import Combine
import SpotifyWebAPI

struct ArtistView: View {
    let artist: Artist

    @EnvironmentObject var spotify: Spotify

    @State var relatedArtists: [Artist] = []
    @State private var cancellables: Set<AnyCancellable> = []
    @State private var addToPlaylistPopover = false
    @State private var playlistSettings = PlaylistSettings()

    var body: some View {
        Form {
            if !relatedArtists.isEmpty {
                Section("Related Artists") {
                    ForEach(relatedArtists) { relatedArtist in
                        NavigationLink {
                            ArtistView(artist: relatedArtist)
                        } label: {
                            ArtistCell(artist: relatedArtist)
                        }
                    }
                }
            }
        }
        .navigationTitle(artist.name)
        .task {
            do {
                var clearList = true
                for try await batch in spotify.api.relatedArtists(artist.uri!, in: &cancellables) {
                    if clearList {
                        self.relatedArtists = [artist]
                        clearList = false
                    }
                    for relatedArtist in batch {
                        relatedArtists.insertSorted(relatedArtist, by: Artist.popularityDescending)
                    }
                }
            } catch {
                print(error)
            }
        }
        .navigationBarItems(trailing: NavigationLink {
            PlaylistSettingsView(settings: $playlistSettings)
        } label: { Image(systemName: "gear")})
        .navigationBarItems(trailing: NavigationLink {
            PlaylistWizard(artist: artist, settings: playlistSettings)
        } label: {
            Image(systemName: "text.badge.star")
        })
    }
}

#Preview {
    NavigationStack {
        ArtistView(artist: Artist.crumb)
    }
    .environmentObject(Spotify())
}

#Preview("RelatedArtists") {
    let relatedArtists: [Artist] = [
        .pinkFloyd, .radiohead, .skinshape, .theBeatles,
    ]

    return NavigationStack {
        ArtistView(artist: Artist.crumb, relatedArtists: relatedArtists)
    }
    .environmentObject(Spotify())
}
