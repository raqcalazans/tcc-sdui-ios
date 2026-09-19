import SwiftUI

struct FanRegistrationView: View {
    @StateObject private var viewModel = FanRegistrationViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if let screen = viewModel.screen {
                    Form {
                        ForEach(screen.components) { component in
                            renderComponent(component)
                        }
                        
                        Section {
                            Button(action: {
                                viewModel.submitForm()
                            }) {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .frame(maxWidth: .infinity)
                                } else {
                                    Text(screen.submitButton.text)
                                        .frame(maxWidth: .infinity)
                                        .bold()
                                }
                            }
                        }
                    }
                    .navigationTitle(screen.screenTitle)
                    .navigationBarTitleDisplayMode(.inline)
                    
                } else if viewModel.isLoading {
                    ProgressView("Carregando formulário...")
                    
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            .navigationDestination(isPresented: $viewModel.isSubmitted) {
                GameListView()
            }
        }
        .onAppear {
            viewModel.fetchScreenData()
        }
    }
    
    @ViewBuilder
    private func renderComponent(_ component: Component) -> some View {
        VStack(alignment: .leading) {
            switch component.type {
            case "TEXT_FIELD":
                TextField(component.label, text: textBinding(for: component.id))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
            case "DROP_DOWN":
                Picker(component.label, selection: textBinding(for: component.id)) {
                    Text("Selecione...").tag("")
                    if let options = component.options {
                        ForEach(options) { option in
                            Text(option.label).tag(option.id)
                        }
                    }
                }
                
            case "RADIO_GROUP":
                VStack(alignment: .leading) {
                    Text(component.label).font(.caption).foregroundColor(.gray)
                    Picker(component.label, selection: textBinding(for: component.id)) {
                        if let options = component.options {
                            ForEach(options) { option in
                                Text(option.label).tag(option.id)
                            }
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
            case "TOGGLE":
                Toggle(component.label, isOn: boolBinding(for: component.id))
                
            default:
                Text("Componente não suportado: \(component.type)")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Helpers Dinâmicos
    
    private func textBinding(for key: String) -> Binding<String> {
        Binding(
            get: { viewModel.formData[key, default: ""] },
            set: { viewModel.formData[key] = $0 }
        )
    }
    
    private func boolBinding(for key: String) -> Binding<Bool> {
        Binding(
            get: { viewModel.formData[key] == "true" },
            set: { viewModel.formData[key] = $0 ? "true" : "false" }
        )
    }
}
