//
//  LocationsScreen.swift
//  secondCamera
//
//  Created by Filip Šašala on 15/05/2023.
//

import Combine
import SwiftUI
import SharedObject

final class LocationsModel: ObservableObject {

    @SharedObject(C.dependencyContainer) var di: DependencyContainer

    private var cancellables = Set<AnyCancellable>()

    init() {
        di.cacheManager.savedLocations.publisher
            .map { _ in () }
            .sink { [weak self] in
                guard let self else { return }
                objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    var locations: [Location] {
        di.cacheManager.savedLocations
    }

}

struct LocationsScreen: View {

    @StateObject private var viewModel = LocationsModel()
    @State private var newLocation: Location? = nil

    var body: some View {
        List {
            ForEach(viewModel.locations) { location in
                NavigationLink(value: location.id, label: {
                    locationView(for: location)
                })
            }
        }
        .toolbar {
            Button(action: {
                newLocation = Location()
            }, label: {
                Icon(.plus)
            })
        }
        .navigationTitle("Lokácie")
        .sheet(isPresented: $newLocation.isNotNil, content: {
            NavigationStack { CreateLocationScreen(newLocation: $newLocation) }
        })
    }

    func locationView(for location: Location) -> some View {
        HStack {
            Icon(.album)
                .foregroundColor(Color.accentColor)
                .frame(width: 24, height: 24)
                .padding()

            VStack(alignment: .leading, spacing: 8) {
                Text(location.type.rawValue)
                Text(location.type.rawValue)
                    .font(.subheadline)
            }
        }
    }

}

struct LocationsScreen_Previews: PreviewProvider {

    static var previews: some View {
        NavigationStack {
            LocationsScreen()
        }
    }

}
