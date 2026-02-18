import UIKit

@Observable
final class ResultViewModel {
    var description: String = ""
    var isLoading = false
    var errorMessage: String?

    func generateDescription(for image: UIImage?) async {
        guard let image else {
            errorMessage = "No image provided."
            return
        }

        isLoading = true
        errorMessage = nil
        description = ""

        do {
            description = try await OpenAIService.describeItem(from: image)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
