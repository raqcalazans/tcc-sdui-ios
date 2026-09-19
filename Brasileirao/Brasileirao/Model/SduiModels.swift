import Foundation

struct FormScreen: Codable {
    let screenTitle: String
    let components: [Component]
    let submitButton: ButtonDTO
}

struct ButtonDTO: Codable {
    let text: String
    let url: String
}

// Modelo de cada componente visual (TextField, DropDown, etc)
struct Component: Codable, Identifiable {
    let id: String
    let type: String
    let label: String
    let required: Bool
    let options: [Option]? // Opcional, pois TextFields e Toggles não têm opções
}

// Modelo para as opções do DropDown e RadioGroup
struct Option: Codable, Identifiable {
    let id: String
    let label: String
}
