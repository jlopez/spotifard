//
//  ToolbarCloseButton.swift
//  Spotifard
//
//  Created by Jesus Lopez on 12/1/23.
//

import SwiftUI

struct ToolbarCloseButton: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Button("Cancel", systemImage: "xmark.circle.fill") { dismiss() }
            .keyboardShortcut(.cancelAction)
            .foregroundColor(.secondary)
            .buttonStyle(.plain)
    }
}

extension View {
    func toolbarCloseButton() -> some View {
        self.toolbar { ToolbarItem(placement: .topBarTrailing) { ToolbarCloseButton() } }
    }
}

#Preview("Sheet") {
    struct Container: View {
        @State var show = true
        var body: some View {
            NavigationStack {
                HStack {}
                    .navigationTitle("Parent")
                    .toolbar { Button("Show", systemImage: "slider.horizontal.3") { show.toggle() } }
                    .sheet(isPresented: $show, onDismiss: {
                    }) {
                        NavigationStack {
                            HStack {}
                                .navigationTitle("Sheet")
                                .toolbarCloseButton()
                        }
                    }
            }
        }
    }
    return Container()
}

#Preview("Standalone") {
    ToolbarCloseButton()
}
