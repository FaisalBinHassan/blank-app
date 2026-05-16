import SwiftUI

@main
struct KeyboardAIApp: App {
    @StateObject private var settings = SharedSettings.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
        }
    }
}
