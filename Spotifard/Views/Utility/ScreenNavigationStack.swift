//
//  EnvironmentNavigationStack.swift
//  Spotifard
//
//  Created by Jesus Lopez on 2/27/24.
//

import SwiftUI

@MainActor struct ScreenNavigationStack<Root>: View where Root : View {
    @State private var navigationModel = NavigationModel()
    private let root: () -> Root

    @MainActor init(@ViewBuilder root: @escaping () -> Root) {
        self.root = root
    }

    var body: some View {
        NavigationStack(path: $navigationModel.path) {
            root()
                .navigationDestination(for: Screen.self) { $0.createView() }
                .navigationDestination(for: ParameterizedScreen.self) { $0.createView() }
        }
        .environment(navigationModel)
    }
}

#Preview {
    ScreenNavigationStack {
        List {
            Text("Row 1")
            Text("Row 2")
        }
        .navigationTitle("Root")
    }
}
