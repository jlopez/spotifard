//
//  TrackFilterView.swift
//  Spotifard
//
//  Created by Jesus Lopez on 11/30/23.
//

import SwiftUI

struct TrackFilterView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        List {
        }
        .toolbar { Button { dismiss() } label: { Text("Cancel") } }
    }
}

struct TrackFilter {
    var popularity: Int
}

#Preview {
    TrackFilterView()
}
