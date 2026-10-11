import XCTest
@testable import AmantesDoFutebol

final class FanDateFormatterTests: XCTestCase {
    func testDisplayConvertsISODateToBrazilianFormat() {
        XCTAssertEqual(FanDateFormatter.display("1995-08-14"), "14/08/1995")
    }

    func testStorageConvertsBrazilianDateToISOFormat() {
        XCTAssertEqual(FanDateFormatter.storage("14/08/1995"), "1995-08-14")
    }

    func testInvalidDatesAreReturnedUnchanged() {
        XCTAssertEqual(FanDateFormatter.display("2023-02-29"), "2023-02-29")
        XCTAssertEqual(FanDateFormatter.storage("31/02/2000"), "31/02/2000")
    }

    func testMaskAddsSeparatorsAndLimitsInputToEightDigits() {
        XCTAssertEqual(FanDateFormatter.mask("14081995"), "14/08/1995")
        XCTAssertEqual(FanDateFormatter.mask("14a081995123"), "14/08/1995")
    }

    func testAgeBeforeAndOnBirthday() throws {
        let beforeBirthday = try makeDate(year: 2026, month: 8, day: 13)
        let onBirthday = try makeDate(year: 2026, month: 8, day: 14)

        XCTAssertEqual(FanDateFormatter.age(from: "2000-08-14", asOf: beforeBirthday), 25)
        XCTAssertEqual(FanDateFormatter.age(from: "2000-08-14", asOf: onBirthday), 26)
    }

    func testAgeIsNilForInvalidOrFutureBirthDate() throws {
        let today = try makeDate(year: 2026, month: 8, day: 14)

        XCTAssertNil(FanDateFormatter.age(from: "2023-02-29", asOf: today))
        XCTAssertNil(FanDateFormatter.age(from: "2030-01-01", asOf: today))
    }

    private func makeDate(year: Int, month: Int, day: Int) throws -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = 12
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        return try XCTUnwrap(calendar.date(from: components))
    }
}
