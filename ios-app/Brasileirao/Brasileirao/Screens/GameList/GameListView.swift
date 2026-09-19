import SwiftUI

struct GameListView: View {
    
    @StateObject private var viewModel: GameListViewModel
    
    init() {
        _viewModel = StateObject(wrappedValue: GameListViewModel())
    }
    
    var body: some View {
        NavigationStack {
            
            VStack(spacing: 0) {

                if viewModel.currentGroup != nil {
                    FilterHeaderView(
                        currentStatusTitle: viewModel.currentGroup!.title,
                        onPrevious: { viewModel.selectPreviousGroup() },
                        onNext: { viewModel.selectNextGroup() }
                    )
                    .padding(.horizontal)
                    .background(Color(.systemGray6))
                }

                ZStack {
                    if viewModel.isLoading && viewModel.groups.isEmpty {
                        ProgressView(String(localized: "loading_games_message"))
                    } else if let group = viewModel.currentGroup, !group.games.isEmpty {
                        List(group.games, id: \.id) { gameDTO in
                            VStack(spacing: 0) {
                                ZStack {
                                    NavigationLink(destination: GameDetailContainerView(gameID: gameDTO.id)) {
                                        EmptyView()
                                    }
                                    .opacity(0)
                                    
                                    GameView(gameDTO: gameDTO, groupTitle: group.title, style: .row)
                                        .padding(.horizontal, 16)
                                }
                                
                                Divider()
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                        }
                        .listStyle(.plain)
                        .refreshable { await viewModel.syncGames() }
                    } else {
                        ContentUnavailableView(
                            String(localized: "empty_list_title"),
                            systemImage: "soccerball.inverse",
                            description: Text(
                                String(localized:
                                        "game_list_empty_state_description \(viewModel.currentGroup?.title ?? "")"
                                      )
                                )
                        )
                    }
                    
                    if viewModel.isLoading && !viewModel.groups.isEmpty {
                        ProgressView()
                            .padding()
                            .background(Material.thin)
                            .cornerRadius(10)
                    }
                }
            }
            .navigationTitle(String(localized: "game_list_screen_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {}) { Image(systemName: "arrow.left").foregroundColor(.primary) }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { Task { await viewModel.syncGames() } }) {
                        Image(systemName: "arrow.clockwise").foregroundColor(.primary)
                    }
                }
            }
            
            .task {
                await viewModel.syncGames()
            }

            .alert(String(localized: "network_error_alert_title"), isPresented: .constant(viewModel.errorMessage != nil), actions: {
                Button(String(localized: "alert_button_ok")) { viewModel.errorMessage = nil }
            }, message: {
                Text(viewModel.errorMessage ?? "Ocorreu um erro desconhecido.")
            })
        }
    }
}

struct FilterHeaderView: View {
    let currentStatusTitle: String
    let onPrevious: () -> Void
    let onNext: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onPrevious) {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Text(currentStatusTitle)
                .font(.headline)
                .frame(minWidth: 120)
            Spacer()
            Button(action: onNext) {
                Image(systemName: "chevron.right")
            }
        }
        .foregroundColor(.primary)
        .padding(.vertical, 8)
    }
}
