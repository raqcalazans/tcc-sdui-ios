import Foundation

struct TeamDTO: Codable {
    let id: Int
    let name: String
    let acronym: String
    let logoURL: URL
    let description: String
}
