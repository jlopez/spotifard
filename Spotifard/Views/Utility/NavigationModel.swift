//
//  NavigationModel.swift
//  Spotifard
//
//  Created by Jesus Lopez on 2/27/24.
//

import SwiftUI
import SpotifyWebAPI

@Observable
class NavigationModel {
    var path = NavigationPath()
}

enum Screen: CaseIterable {
    case playlists
    case artists
    case savedAlbums
    case searchForTracks
    case searchForArtists
    case recentlyPlayed
    case debugMenu

    var title: String {
        switch self {
            case .playlists:        return "Playlists"
            case .artists:          return "Artists"
            case .savedAlbums:      return "Saved Albums"
            case .searchForTracks:  return "Search For Tracks"
            case .searchForArtists: return "Search For Artists"
            case .recentlyPlayed:   return "Recently Played"
            case .debugMenu:        return "Debug Menu"
        }
    }

    @ViewBuilder
    func createView() -> some View {
        switch self {
            case .playlists:        PlaylistsListView()
            case .artists:          ArtistsView()
            case .savedAlbums:      SavedAlbumsGridView()
            case .searchForTracks:  SearchForTracksView()
            case .searchForArtists: SearchForArtistsView()
            case .recentlyPlayed:   RecentlyPlayedView()
            case .debugMenu:        DebugMenuView()
        }
    }
}

enum ParameterizedScreen: Hashable {
    case guessTheSong(Playlist<PlaylistItemsReference>)

    @ViewBuilder
    func createView() -> some View {
        switch self {
            case .guessTheSong(let playlist):
                GuessTheSongView(playlist: playlist)
        }
    }
}

