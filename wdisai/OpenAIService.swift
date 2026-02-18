import UIKit

// Must be a vision-capable model (supports image inputs).
private let MODEL_NAME = "gpt-4.1-mini"

enum OpenAIService {
    private static let endpoint = URL(string: "https://api.openai.com/v1/responses")!

    enum ServiceError: LocalizedError {
        case imageEncodingFailed
        case httpError(statusCode: Int, message: String)
        case noTextInResponse

        var errorDescription: String? {
            switch self {
            case .imageEncodingFailed:
                "Failed to encode the image as JPEG."
            case .httpError(let code, let message):
                "OpenAI API error (\(code)): \(message)"
            case .noTextInResponse:
                "The API returned a response with no text content."
            }
        }
    }

    /// Sends the image to OpenAI and returns a short description.
    static func describeItem(from image: UIImage) async throws -> String {
        let apiKey = try APIKeyProvider.apiKey()

        guard let dataURL = image.jpegBase64DataURL() else {
            throw ServiceError.imageEncodingFailed
        }

        let body: [String: Any] = [
            "model": MODEL_NAME,
            "input": [
                [
                    "role": "user",
                    "content": [
                        ["type": "input_text", "text": "Describe the main item in this image in 1–2 sentences. If unsure, say so."],
                        ["type": "input_image", "image_url": dataURL]
                    ]
                ]
            ]
        ]

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
        guard (200..<300).contains(statusCode) else {
            let serverMessage = parseErrorMessage(from: data) ?? String(data: data, encoding: .utf8) ?? "Unknown error"
            throw ServiceError.httpError(statusCode: statusCode, message: serverMessage)
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw ServiceError.noTextInResponse
        }

        if let outputText = json["output_text"] as? String, !outputText.isEmpty {
            return outputText
        }

        if let text = extractTextFromOutput(json) {
            return text
        }

        throw ServiceError.noTextInResponse
    }

    // MARK: - Parsing helpers

    private static func extractTextFromOutput(_ json: [String: Any]) -> String? {
        guard let output = json["output"] as? [[String: Any]] else { return nil }
        var texts: [String] = []
        for item in output {
            guard let content = item["content"] as? [[String: Any]] else { continue }
            for piece in content {
                if let text = piece["text"] as? String {
                    texts.append(text)
                }
            }
        }
        let joined = texts.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
        return joined.isEmpty ? nil : joined
    }

    private static func parseErrorMessage(from data: Data) -> String? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        if let error = json["error"] as? [String: Any], let message = error["message"] as? String {
            return message
        }
        return nil
    }
}
