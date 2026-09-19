import Foundation

enum TestError: Error, LocalizedError {
    case networkFailed
    
    var errorDescription: String? {
        switch self {
        case .networkFailed:
            return "A simulated network request failed."
        }
    }
}
