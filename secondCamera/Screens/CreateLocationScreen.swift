//
//  CreateLocationScreen.swift
//  secondCamera
//
//  Created by Filip Šašala on 18/05/2023.
//

import SwiftUI
import SharedObject

final class CreateLocationModel: ObservableObject {

    @SharedObject(C.dependencyContainer) var di: DependencyContainer

    func saveLocation(_ location: Location) {
        di.cacheManager.saveLocation(location)
    }

}

struct CreateLocationScreen: View {

    @StateObject private var viewModel = CreateLocationModel()
    @Binding var newLocation: Location

    var body: some View {
        Form {
            Section("Typ lokácie") {
                Picker("Ukladať fotografie do:", selection: $newLocation.type) {
                    Text("Album")
                        .tag(LocationType.album)

                    Text("Priečinok")
                        .tag(LocationType.folder)
                }
            }
            Section("Názov") {
                TextField("Môj album", text: $newLocation.name)
            }

            Button(action: {

            }, label: {
                Text("Pridať novú lokáciu")
            })
            .disabled(newLocation.name.isEmpty)
        }
        .navigationTitle("Pridať lokáciu")
    }

}

struct CreateLocationScreen_Previews: PreviewProvider {

    static var previews: some View {
        NavigationStack {
            CreateLocationScreen(newLocation: .constant(Location()))
        }
    }

}
