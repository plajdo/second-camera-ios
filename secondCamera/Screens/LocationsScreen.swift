//
//  LocationsScreen.swift
//  secondCamera
//
//  Created by Filip Šašala on 15/05/2023.
//

import SwiftUI

struct LocationsScreen: View {

    var body: some View {
        List {
            NavigationLink(value: "1", label: {
                locationView()
            })
            NavigationLink(value: "2", label: {
                locationView()
            })
            NavigationLink(value: "3", label: {
                locationView()
            })
            NavigationLink(value: "4", label: {
                locationView()
            })
        }
        .navigationTitle("Lokácie")
    }

    func locationView() -> some View {
        HStack {
            Icon(.album)
                .foregroundColor(Color.accentColor)
                .frame(width: 24, height: 24)
                .padding()

            VStack(alignment: .leading, spacing: 8) {
                Text("Galéria")

                Text("Album: 1234")
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
