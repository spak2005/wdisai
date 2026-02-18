import SwiftUI

enum Route: Hashable {
    case camera
    case result
}

@Observable
final class AppViewModel {
    var path = NavigationPath()
    var selectedImage: UIImage?

    func navigateToCamera() {
        path.append(Route.camera)
    }

    func navigateToResult(with image: UIImage) {
        selectedImage = image
        path.append(Route.result)
    }

    func goHome() {
        selectedImage = nil
        path = NavigationPath()
    }
}
