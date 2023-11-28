//
//  SpotifardApp.swift
//  Spotifard
//
//  Created by Jesus Lopez on 11/19/23.
//

import SwiftUI
import SpotifyWebAPI

@main
struct SpotifardApp: App {
    @StateObject var spotify = Spotify()

    init() {
        SpotifyAPILogHandler.bootstrap()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(spotify)
        }
    }
}
