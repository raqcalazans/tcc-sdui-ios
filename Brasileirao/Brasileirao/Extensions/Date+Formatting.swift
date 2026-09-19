import Foundation
import SwiftUI

extension Date {

    var gameDayDisplay: String {
        let calendar = Calendar.current
        
        if calendar.isDateInTomorrow(self) {
            return String(localized: "date_formatter_tomorrow")
        }
        if calendar.isDateInToday(self) {
            return String(localized: "date_formatter_today")
        }
        if calendar.isDateInYesterday(self) {
            return String(localized: "date_formatter_yesterday")
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
    
    var gameTimeDisplay: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}
