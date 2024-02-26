//
//  ArtistsView.swift
//  Spotifard
//
//  Created by Jesus Lopez on 2/11/24.
//

import SwiftUI
import SpotifyWebAPI

struct ArtistsView: View {
    @State private var searchText = ""
    @State private var artists = [Artist]()
    @State private var next: URL? = nil
    @EnvironmentObject private var spotify: Spotify

    var body: some View {
        List(artists, id: \.uri) { artist in
            NavigationLink {
                ArtistTracksView(artist: artist)
            } label: {
                ArtistCell(artist: artist)
            }
        }
        .searchable(text: $searchText, prompt: "Artist Name")
        .navigationTitle("Artists")
        .task(id: searchText, searchArtists)
    }

    @Sendable
    func searchArtists() async {
        do {
            try await Task.sleep(nanoseconds: 500_000_000)
            for try await result in spotify.api.search(
                query: searchText,
                categories: [.artist]
            ).values {
                artists.append(contentsOf: result.artists?.items ?? [])
                next = result.artists?.next
            }
        } catch {
            print("Error searching artists: \(error)")
        }
    }
}

#Preview {
    NavigationView {
        ArtistsView()
    }
    .environmentObject(Spotify())
}
