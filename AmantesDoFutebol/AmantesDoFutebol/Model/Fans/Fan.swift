import Foundation

struct Fan: Codable, Identifiable, Hashable {
    let id: Int
    var name: String
    var email: String
    var birthDate: String
    var gender: String
    var favoriteTeamId: String
    var city: String
    var state: String
    var country: String
    var stadiumFrequency: String

    var location: String { [city, state, country].joined(separator: ", ") }
}

enum FanDateFormatter {
    static func display(_ value: String) -> String { transform(value, from: "yyyy-MM-dd", to: "dd/MM/yyyy") ?? value }
    static func storage(_ value: String) -> String { transform(value, from: "dd/MM/yyyy", to: "yyyy-MM-dd") ?? value }

    static func age(from value: String, asOf date: Date = Date()) -> Int? {
        let formatter = formatter("yyyy-MM-dd", timeZone: .current)
        guard let birthDate = formatter.date(from: value), formatter.string(from: birthDate) == value else { return nil }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        guard let age = calendar.dateComponents([.year], from: birthDate, to: date).year, age >= 0 else { return nil }
        return age
    }

    static func mask(_ value: String) -> String {
        let digits = String(value.filter(\.isNumber).prefix(8))
        var result = ""
        for (index, digit) in digits.enumerated() {
            if index == 2 || index == 4 { result += "/" }
            result.append(digit)
        }
        return result
    }

    private static func transform(_ value: String, from input: String, to output: String) -> String? {
        let inputFormatter = formatter(input)
        guard let date = inputFormatter.date(from: value), inputFormatter.string(from: date) == value else { return nil }
        return formatter(output).string(from: date)
    }

    private static func formatter(_ format: String, timeZone: TimeZone = TimeZone(secondsFromGMT: 0) ?? .current) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = timeZone
        formatter.isLenient = false
        formatter.dateFormat = format
        return formatter
    }
}
