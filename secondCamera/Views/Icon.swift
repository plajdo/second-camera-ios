//
//  Icon.swift
//  secondCamera
//
//  Created by Filip Šašala on 15/05/2023.
//

import SwiftUI

struct Icon: View {

    let iconImage: IconImage

    init(_ iconImage: IconImage) {
        self.iconImage = iconImage
    }

    var body: some View {
        Image(systemName: iconImage.rawValue)
            .resizable(resizingMode: .stretch)
            .aspectRatio(contentMode: .fill)
    }

}

enum IconImage: String {

    case switchCamera = "arrow.triangle.2.circlepath.camera"
    case photoStack = "photo.stack.fill"
    case album = "person.2.crop.square.stack.fill"
    case plus = "plus.app"

}

struct Icon_Previews: PreviewProvider {

    static var previews: some View {
        Icon(.switchCamera)
            .background { Color.black.padding(-64) }
            .foregroundColor(Color.white)
            .frame(width: 100, height: 100)
            .fixedSize()
    }

}
