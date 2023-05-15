//
//  ContentView.swift
//  secondCamera
//
//  Created by Filip Šašala on 15/05/2023.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: secondCameraDocument

    var body: some View {
        TextEditor(text: $document.text)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(secondCameraDocument()))
    }
}
