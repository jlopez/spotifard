//
//  SearchBar.swift
//  Spotifard
//
//  Created by Jesus Lopez on 11/28/23.
//

import SwiftUI

struct SearchBar: View {
    @Binding var searchTerm: String

    var body: some View {
        TextField("Playlist Name", text: $searchTerm)
            .padding(.leading, 22)
            .overlay(
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    Spacer()
                    if !searchTerm.isEmpty {
                        // Clear the search text when the user taps the "x" button.
                        Button {
                            searchTerm = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            )
            .padding(.vertical, 7)
            .padding(.horizontal, 7)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            .padding(.horizontal)
            .textContentType(.name)
            .textInputAutocapitalization(.never)
    }
}

#Preview {
    @State var searchTerm = ""

    return VStack {
        SearchBar(searchTerm: $searchTerm)
        Spacer()
        List {
            Text("Some item")
        }
        .listStyle(.plain)
    }
}
