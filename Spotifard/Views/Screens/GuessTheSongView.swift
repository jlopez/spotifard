//
//  GuessTheSongView.swift
//  Spotifard
//
//  Created by Jesus Lopez on 2/25/24.
//

import SwiftUI
import SpotifyWebAPI

struct GuessTheSongView: View {
    let playlist: Playlist<PlaylistItemsReference>

    var body: some View {
        Text("Guess the song: \(playlist.name)")
    }
}

#Preview {
    GuessTheSongView(playlist: .lucyInTheSkyWithDiamonds)
}
