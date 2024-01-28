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

// https://forums.swift.org/t/rawrepresentable-conformance-leads-to-crash/51912/4
struct CodableWrapper<Value: Codable> {
    var value: Value
}

extension CodableWrapper: RawRepresentable {

    typealias RawValue = String

    var rawValue: RawValue {
        guard let data = try? JSONEncoder().encode(value),
              let string = String(data: data, encoding: .utf8)
        else { return "{}" }
        return string
    }

    init?(rawValue: RawValue) {
        guard let data = rawValue.data(using: .utf8),
              let decoded = try? JSONDecoder().decode(Value.self, from: data)
        else { return nil }
        value = decoded
    }
}

extension CodableWrapper: Equatable where Value : Equatable {}

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
