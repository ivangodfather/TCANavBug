//
//  Root.swift
//  NewTCAExample
//
//  Created by Iván Ruiz Monjo on 5/5/23.
//

import ComposableArchitecture
import SwiftUI

enum RootTab {
    case number
    case navigation
    case stack
}

struct RootFeature: Reducer {
    struct State: Equatable {
        var navigation = NavigationFeature.State()
        var stack = StackNavFeature.State()

        var selectedTab = RootTab.number
    }

    enum Action: Equatable {
        case navigation(NavigationFeature.Action)
        case stack(StackNavFeature.Action)

        case selectedTab(RootTab)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .navigation:
                return .none
            case let .selectedTab(tab):
                state.selectedTab =  tab
                return .none
            case .stack:
                return .none
            }
        }
        Scope(state: \.navigation, action: /RootFeature.Action.navigation) {
            NavigationFeature()
        }
        Scope(state: \.stack, action: /RootFeature.Action.stack) {
            StackNavFeature()
        }
    }
}

struct RootView: View {
    let store: StoreOf<RootFeature>

    var body: some View {
        WithViewStore(store, observe: \.selectedTab) { viewStore in
            TabView(selection: viewStore.binding(get: { $0 }, send: RootFeature.Action.selectedTab)) {
                NavigationStack {
                    NavigationExampleView(
                        store: store.scope(
                            state: \.navigation,
                            action: RootFeature.Action.navigation
                        )
                    )
                }
                    .tag(RootTab.navigation)
                    .tabItem {
                        Image(systemName: "figure.sailing")
                        Text("Navigation")
                    }
                StackNavView(
                    store: store.scope(
                        state: \.stack,
                        action: RootFeature.Action.stack
                    )
                )
                    .tag(RootTab.stack)
                    .tabItem {
                        Image(systemName: "square.stack.3d.down.forward")
                        Text("StackNav")
                    }
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(store: .init(
            initialState: .init(),
            reducer: RootFeature())
        )
    }
}
