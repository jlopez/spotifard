//
//  ContentView.swift
//  Spotifard
//
//  Created by Jesus Lopez on 11/19/23.
//

import SwiftUI
import Combine
import SpotifyWebAPI

struct ContentView: View {
    @EnvironmentObject var spotify: Spotify
    @State private var navigationModel = NavigationModel()
    @State private var alert: AlertItem?
    @State private var showAuthorizationAlert = false

    @State private var cancellables: Set<AnyCancellable> = []

    var body: some View {
        ScreenNavigationStack {
            ExamplesListView()
                .disabled(!spotify.isAuthorized)
                .toolbar {
                    Button("Log Out", systemImage: "power", action: spotify.api.authorizationManager.deauthorize)
                }
        }
        .modifier(LoginView())
        .alert("Authorization Error",
               isPresented: $showAuthorizationAlert,
               presenting: alert) { alert in
            Button("OK", role: .cancel) { }
        } message: { alert in
            alert.title
            alert.message
        }
        .onOpenURL(perform: handleURL(_:))
    }

    /**
     Handle the URL that Spotify redirects to after the user Either authorizes
     or denies authorization for the application.

     This method is called by the `onOpenURL(perform:)` view modifier directly
     above.
     */
    func handleURL(_ url: URL) {

        // **Always** validate URLs; they offer a potential attack vector into
        // your app.
        guard url.scheme == self.spotify.loginCallbackURL.scheme else {
            print("not handling URL: unexpected scheme: '\(url)'")
            self.alert = AlertItem(
                title: "Cannot Handle Redirect",
                message: "Unexpected URL"
            )
            return
        }

        print("received redirect from Spotify: '\(url)'")

        // This property is used to display an activity indicator in `LoginView`
        // indicating that the access and refresh tokens are being retrieved.
        spotify.isRetrievingTokens = true

        // Complete the authorization process by requesting the access and
        // refresh tokens.
        spotify.api.authorizationManager.requestAccessAndRefreshTokens(
            redirectURIWithQuery: url,
            // Must match the code verifier that was used to generate the
            // code challenge when creating the authorization URL.
            codeVerifier: spotify.codeVerifier,
            // This value must be the same as the one used to create the
            // authorization URL. Otherwise, an error will be thrown.
            state: spotify.authorizationState
        )
        .receive(on: RunLoop.main)
        .sink(receiveCompletion: { completion in
            // Whether the request succeeded or not, we need to remove the
            // activity indicator.
            self.spotify.isRetrievingTokens = false

            /*
             After the access and refresh tokens are retrieved,
             `SpotifyAPI.authorizationManagerDidChange` will emit a signal,
             causing `Spotify.authorizationManagerDidChange()` to be called,
             which will dismiss the loginView if the app was successfully
             authorized by setting the @Published `Spotify.isAuthorized`
             property to `true`.

             The only thing we need to do here is handle the error and show it
             to the user if one was received.
             */
            if case .failure(let error) = completion {
                print("couldn't retrieve access and refresh tokens:\n\(error)")
                let alertTitle: String
                let alertMessage: String
                if let authError = error as? SpotifyAuthorizationError,
                   authError.accessWasDenied {
                    alertTitle = "You Denied The Authorization Request :("
                    alertMessage = ""
                }
                else {
                    alertTitle =
                    "Couldn't Authorization With Your Account"
                    alertMessage = error.localizedDescription
                }
                self.alert = AlertItem(
                    title: alertTitle, message: alertMessage
                )
            }
        })
        .store(in: &cancellables)

        // MARK: IMPORTANT: generate a new value for the state parameter after
        // MARK: each authorization request. This ensures an incoming redirect
        // MARK: from Spotify was the result of a request made by this app, and
        // MARK: and not an attacker.
        self.spotify.codeVerifier = String.randomURLSafe(length: 128)
        self.spotify.authorizationState = String.randomURLSafe(length: 128)

    }
}

#Preview("Normal") {
    return ContentView()
        .environmentObject(Spotify())
}

#Preview("Authorized") {
    let spotify = Spotify()
    spotify.isAuthorized = true

    return ContentView()
        .environmentObject(spotify)
}

#Preview("Not authorized") {
    let spotify = Spotify()
    spotify.isAuthorized = false

    return ContentView()
        .environmentObject(spotify)
}
