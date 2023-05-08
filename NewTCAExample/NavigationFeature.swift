//
//  NavigationFeature.swift
//  NewTCAExample
//
//  Created by Iván Ruiz Monjo on 5/5/23.
//

import ComposableArchitecture
import SwiftUI

struct NavigationFeature: Reducer {
    struct State: Equatable {
        let item = Item(name: "Pencil")
        @PresentationState var destination: Destination.State?
    }
    
    enum Action: Equatable {
        case destination(PresentationAction<Destination.Action>)
        case showItemAsNavigation(Item)
    }
    
    struct Destination: Reducer {
        enum State: Equatable {
            case itemAsNavigation(ItemFeature.State)
        }
        
        enum Action: Equatable {
            case itemAsNavigation(ItemFeature.Action)
        }
        
        var body: some ReducerOf<Self> {
            Scope(state: /State.itemAsNavigation, action: /Action.itemAsNavigation) {
                ItemFeature()
            }
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .destination(.dismiss):
                state.destination = nil
                return .none
            case .destination:
                return .none
            case .showItemAsNavigation(let item):
                state.destination = .itemAsNavigation(.init(item: item))
                return .none
            }
        }
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
    }
}

struct NavigationExampleView: View {
    let store: StoreOf<NavigationFeature>
    
    var body: some View {
        WithViewStore(store, observe: \.item) { viewStore in
            VStack(spacing: 16) {
                Button {
                    viewStore.send(.showItemAsNavigation(viewStore.state))
                } label: {
                    VStack {
                        Text("Item as link")
                        Text("Only works from the navigation tab")
                    }
                }
            }
            .navigationDestination(
                store: store.scope(state: \.$destination, action: NavigationFeature.Action.destination),
                state: /NavigationFeature.Destination.State.itemAsNavigation,
                action: NavigationFeature.Destination.Action.itemAsNavigation,
                destination: ItemView.init
            )
        }
    }
}

struct NavigationExampleView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationExampleView(
            store: .init(initialState: .init(), reducer: NavigationFeature())
        )
    }
}
