//
//  TrackFilterView.swift
//  Spotifard
//
//  Created by Jesus Lopez on 11/30/23.
//

import SwiftUI
import SpotifyWebAPI

struct TrackFilterView: View {
    @Binding var filter: TrackFilter
    @State var showAddMenu: Bool = false

    var body: some View {
        List {
            if filter.enableLiveFM {
                Toggle("Listened on Live.FM", isOn: $filter.liveFM)
            }
            if filter.enableBPM {
                Section("BPM \(filter.bpm.lowerBound, specifier: "%.0f") - \(filter.bpm.upperBound, specifier: "%.0f")") {
                    RangeSlider(value: $filter.bpm, in: 100...200, step: 5) { Text("BPM") }
                }
            }

        }
        .navigationTitle("Track Filtering")
        .toolbarCloseButton()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Menu("Add Filter", systemImage: "plus") {
                    Toggle("Live.fm", isOn: $filter.enableLiveFM)
                    Toggle("BPM", isOn: $filter.enableBPM)
                }
            }
        }
    }
}

struct TrackFilter : Codable {
    var enableLiveFM = false
    var enableBPM = false

    var liveFM = false
    var bpm = 157.0...163.0
    var explicit: Bool?
    var duration: Double = 0
    var popularity: Double = 0
    var danceability: Double = 0
    var energy: Double = 0
    var speechiness: Double = 0
    var acousticness: Double = 0
    var instrumentalness: Double = 0
    var liveness: Double = 0
    var valence: Double = 0
    var tempo: Double = 0
    var timeSignature: Double = 0
    var key: Double = 0
    var mode: Double = 0

    func filter(_ track: TrackAndFeatures) -> Bool {
        if enableBPM && !(bpm.contains(track.features.tempo) || bpm.contains(track.features.tempo * 2)) { return false }
        return true
    }
}

extension TrackFilter : RawRepresentable {
    var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let string = String(data: data, encoding: .utf8)
        else { return "{}" }
        return string
    }
    
    init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
            let result = try? JSONDecoder().decode(TrackFilter.self, from: data)
          else { return }
          self = result
    }

    typealias RawValue = String
}

#Preview("Sheet") {
    struct Container: View {
        @State var show = true
        @State var filter = TrackFilter()
        var body: some View {
            NavigationStack {
                HStack {}
                    .navigationTitle("Parent")
                    .toolbar { Button("Filter", systemImage: "slider.horizontal.3") { show.toggle() } }
                    .sheet(isPresented: $show, onDismiss: {
                    }) {
                        NavigationStack { TrackFilterView(filter: $filter) }
                    }
            }
        }
    }
    return Container()
}
