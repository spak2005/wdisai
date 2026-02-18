import UIKit

extension UIImage {
    /// Compresses the image as JPEG and returns a base64-encoded data URL string.
    nonisolated func jpegBase64DataURL(compressionQuality: CGFloat = 0.7) -> String? {
        guard let data = self.jpegData(compressionQuality: compressionQuality) else { return nil }
        let base64 = data.base64EncodedString()
        return "data:image/jpeg;base64,\(base64)"
    }
}
