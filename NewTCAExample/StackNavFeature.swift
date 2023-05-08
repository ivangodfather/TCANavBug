//
//  StackNavFeature.swift
//  NewTCAExample
//
//  Created by Iván Ruiz Monjo on 8/5/23.
//

import ComposableArchitecture
import SwiftUI

struct StackNavFeature: Reducer {
    struct State: Equatable {
        var path = StackState<Path.State>()
    }
    
    enum Action: Equatable {
        case path(StackAction<Path.State, Path.Action>)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: /Action.path) {
          Path()
        }
    }

    struct Path: Reducer {
        enum State: Equatable {
            case navigation(NavigationFeature.State)
            case item(ItemFeature.State)
        }
        enum Action: Equatable {
            case navigation(NavigationFeature.Action)
            case item(ItemFeature.Action)
        }
        var body: some ReducerOf<Self> {
            Scope(state: /State.navigation, action: /Action.navigation) {
                NavigationFeature()
            }
            Scope(state: /State.item, action: /Action.item) {
                ItemFeature()
            }
        }
    }
}

struct StackNavView: View {
    let store: StoreOf<StackNavFeature>
    
    var body: some View {
        NavigationStackStore(store.scope(state: \.path, action: { .path($0) })) {
            VStack {
                NavigationLink(state: StackNavFeature.Path.State.navigation(.init())) {
                  Text("Go to navigation feature")
                        .bold()
                }
                .padding(.top)
            }
        } destination: { state in
            switch state {
            case .navigation:
              CaseLet(
                state: /StackNavFeature.Path.State.navigation,
                action: StackNavFeature.Path.Action.navigation,
                then: NavigationExampleView.init(store:)
              )
            case .item:  // I image the bug is here, when I click the item feature (embeeded inside navigation) it goes the with navigation switch
              CaseLet(
                state: /StackNavFeature.Path.State.item,
                action: StackNavFeature.Path.Action.item,
                then: ItemView.init(store:)
              )
            }
        }

    }
}

struct ThirdTab_Previews: PreviewProvider {
    static var previews: some View {
        StackNavView(
            store: .init(
                initialState: .init(),
                reducer: StackNavFeature()
            )
        )
    }
}
