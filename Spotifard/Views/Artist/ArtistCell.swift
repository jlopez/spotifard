import SwiftUI
import Combine
import SpotifyWebAPI

struct ArtistCell: View {
    let artist: Artist

    var body: some View {
        HStack {
            SpotifyAsyncImage(images: artist.images)
                .frame(width: 50, height: 50)
            Text(artist.name)
            Spacer()
            VStack(alignment: .trailing) {
                Text("\(artist.followers?.total ?? 0, format: .number)")
                Text("\(artist.popularity?.description ?? "")")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
    }
}

#Preview {
    let artists: [Artist] = [
        .crumb, .levitationRoom, .pinkFloyd, .radiohead, .skinshape, .theBeatles,
    ]

    return List(artists, id: \.id) { artist in
        ArtistCell(artist: artist)
    }
}
