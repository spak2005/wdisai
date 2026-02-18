import Foundation

enum APIKeyProvider {
    enum Error: LocalizedError {
        case missing
        case placeholder

        var errorDescription: String? {
            switch self {
            case .missing:
                "OPENAI_API_KEY not found in Info.plist."
            case .placeholder:
                "OPENAI_API_KEY is still set to the placeholder. Add your real key in Info.plist."
            }
        }
    }

    /// Reads the OpenAI API key from the app's Info.plist.
    static func apiKey() throws -> String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String else {
            throw Error.missing
        }
        guard key != "YOUR_API_KEY_HERE", !key.isEmpty else {
            throw Error.placeholder
        }
        return key
    }
}
