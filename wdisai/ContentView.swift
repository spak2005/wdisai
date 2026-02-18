import SwiftUI

struct ContentView: View {
    @Environment(AppViewModel.self) private var appVM

    var body: some View {
        @Bindable var appVM = appVM

        NavigationStack(path: $appVM.path) {
            HomeScreen(appVM: appVM)
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .camera:
                        CameraScreen(appVM: appVM)
                    case .result:
                        ResultScreen(appVM: appVM)
                    }
                }
        }
    }
}
