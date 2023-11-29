//
//  PlaylistCell.swift
//  Spotifard
//
//  Created by Jesus Lopez on 11/28/23.
//

import SwiftUI
import SpotifyWebAPI

struct PlaylistCell: View {
    let playlist: Playlist<PlaylistItemsReference>

    var body: some View {
        HStack {
            SpotifyAsyncImage(images: playlist.images)
                .frame(width: 50, height: 50)
            Text(playlist.name)
        }
    }
}

#Preview {
    Form {
        PlaylistCell(playlist: Playlist.lucyInTheSkyWithDiamonds)
    }
}
