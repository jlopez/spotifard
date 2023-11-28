import SwiftUI
import Combine

struct DebugMenuView: View {
    
    @EnvironmentObject var spotify: Spotify
    
    @State private var cancellables: Set<AnyCancellable> = []

    var body: some View {
        List {
            Button("Make Access Token Expired") {
                self.spotify.api.authorizationManager.setExpirationDate(
                    to: Date()
                )
            }
            Button("Refresh Access Token") {
                self.spotify.api.authorizationManager.refreshTokens(
                    onlyIfExpired: false
                )
                .sink(receiveCompletion: { completion in
                    print("refresh tokens completion: \(completion)")
                    
                })
                .store(in: &self.cancellables)
            }
            Button("Print SpotifyAPI") {
                print(
                    """
                    --- SpotifyAPI ---
                    \(self.spotify.api)
                    ------------------
                    """
                )
            }
            
        }
        .navigationBarTitle("Debug Menu")
    }
}

#Preview {
    NavigationView {
        DebugMenuView()
    }
    .environmentObject(Spotify())
}
