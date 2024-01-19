//
//  PlaylistSettingsView.swift
//  Spotifard
//
//  Created by Jesus Lopez on 12/5/23.
//

import SwiftUI

struct PlaylistSettingsView: View {
    @Binding var settings: PlaylistSettings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Stepper(value: $settings.artistDepth) { Text("Depth: \(settings.artistDepth)")}
            Stepper(value: $settings.artistCount) { Text("Artists: \(settings.artistCount)")}
            Stepper(value: $settings.trackCount) { Text("Tracks: \(settings.trackCount)")}
        }
        .formStyle(.grouped)
        .navigationTitle("Playlist Settings")
    }
}

#Preview {
    PlaylistSettingsView(settings: .constant(PlaylistSettings()))
}
