//
//  SpotifyImage.swift
//  Spotifard
//
//  Created by Jesus Lopez on 11/28/23.
//

import SwiftUI
import SpotifyWebAPI

struct SpotifyAsyncImage: View {
    let images: [SpotifyImage]?

    var body: some View {
        GeometryReader { geometry in
            AsyncImage(url: pickURL(forSize: geometry.size)) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                Image(.spotifyAlbumPlaceholder)
                    .resizable()
                    .scaledToFit()
            }
        }
    }

    func pickURL(forSize size: CGSize) -> URL? {
        let size = min(size.width, size.height)
        let sortedImages = images?
            .filter { $0.width != nil && $0.height != nil }
            .sorted { $0.width! < $1.width! }
        let bestImage = sortedImages?
            .filter({ $0.width! >= Int(7 * size / 8) })
            .first ?? sortedImages?.last

        #if false
        let dims = sortedImages?.map { "\($0.width!)x\($0.height!)" }
            .map { String(describing: $0) }
            .joined(separator: ", ")
        print("\(dims) -> \(bestImage?.width) for size \(size): \(bestImage?.url)")
        #endif
        
        return bestImage?.url
    }
}



#Preview("Standalone") {
    let artist = Artist.crumb

    return SpotifyAsyncImage(images: artist.images)
}

#Preview("Placeholder") {
    SpotifyAsyncImage(images: [])
}

#Preview("List") {
    let artists: [Artist] = [
        .crumb, .levitationRoom, .pinkFloyd, .radiohead, .skinshape, .theBeatles,
    ]

    return List {
        ForEach(artists, id: \.id) { artist in
            HStack {
                SpotifyAsyncImage(images: artist.images)
                    .frame(width: 50, height: 50)
                Text(artist.name)
            }
        }
        HStack {
            SpotifyAsyncImage(images: [])
                .frame(width: 50, height: 50)
            Text("Unknown")
        }
    }
}
