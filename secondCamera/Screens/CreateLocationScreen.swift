//
//  CreateLocationScreen.swift
//  secondCamera
//
//  Created by Filip Šašala on 18/05/2023.
//

import SwiftUI
import SharedObject

struct CreateLocationScreen: View {

    @EnvironmentObject var viewModel: LocationsViewModel

    @State private var newLocation: Location = Location()
    @Binding var creatingLocation: Bool

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
                viewModel.locations.append(newLocation)
                creatingLocation = false
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
            CreateLocationScreen(creatingLocation: .constant(true))
        }
    }

}
