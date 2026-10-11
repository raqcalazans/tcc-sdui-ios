import Foundation

struct ScreenDefinition: Decodable {
    let screenId: String
    let screenTitle: String
    let screenType: String
    let sections: [ScreenSection]
    let actions: [ScreenAction]
}

struct ScreenSection: Decodable, Identifiable {
    let id: String
    let title: String?
    let components: [ScreenComponent]
}

struct ScreenComponent: Decodable, Identifiable {
    let id: String
    let type: String
    let field: String?
    let fields: [String]?
    let label: String?
    let required: Bool?
    let keyboard: String?
    let placeholder: String?
    let format: String?
    let options: [ScreenOption]?
    let optionsSource: OptionsSource?
    let titleField: String?
    let subtitleField: String?
    let subtitleOptionsSource: OptionsSource?
    let selectAction: String?
}

struct ScreenAction: Decodable, Identifiable {
    let id: String
    let title: String
    let role: String
    let requiresConfirmation: Bool?
}

struct ScreenOption: Decodable, Identifiable, Hashable {
    let id: String
    let label: String
}

struct OptionsSource: Decodable {
    let method: String?
    let path: String
    let valueField: String
    let labelField: String
}
