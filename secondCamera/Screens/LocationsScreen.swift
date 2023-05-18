//
//  LocationsScreen.swift
//  secondCamera
//
//  Created by Filip Šašala on 15/05/2023.
//

import Combine
import SwiftUI
import SharedObject

final class LocationsViewModel: ObservableObject {

    @SharedObject(C.dependencyContainer) var di: DependencyContainer
    
    @Published var locations: [Location] = [] {
        didSet { di.cacheManager.update(locations: locations) }
    }

    init() {
        self.locations = di.cacheManager.savedLocations
    }

}

struct LocationsScreen: View {

    @StateObject private var viewModel = LocationsViewModel()
    @State private var creatingLocation: Bool = false

    var body: some View {
        List {
            ForEach(viewModel.locations) { location in
                NavigationLink(value: location, label: {
                    locationView(for: location)
                })
            }
        }
        .toolbar(content: setupToolbar)
        .navigationTitle("Lokácie")
        .sheet(isPresented: $creatingLocation, content: {
            NavigationStack { CreateLocationScreen(
                creatingLocation: $creatingLocation
            ) }
            .environmentObject(viewModel)
        })
    }

    func setupToolbar() -> some View {
        Button(action: {
            creatingLocation = true
        }, label: {
            Icon(.plus)
        })
    }

    func locationView(for location: Location) -> some View {
        HStack {
            location.type.icon
                .foregroundColor(Color.accentColor)
                .frame(width: 24, height: 24)
                .padding()

            VStack(alignment: .leading, spacing: 8) {
                Text(location.name)
                Text(location.type.localizedName)
                    .font(.subheadline)
            }
        }
        .swipeActions(content: { trashCanSwipeAction(for: location) })
    }

    func trashCanSwipeAction(for location: Location) -> some View {
        Button(action: {
            viewModel.locations.remove(
                at: viewModel.locations.firstIndex(of: location) ?? 0
            )
        }, label: {
            Icon(.trash)
        })
        .tint(.red)
    }

}

struct LocationsScreen_Previews: PreviewProvider {

    static var previews: some View {
        NavigationStack {
            LocationsScreen()
        }
    }

}
