//
//  Glass.swift
//  secondCamera
//
//  Created by Filip Šašala on 15/05/2023.
//

import SwiftUI

struct Glass: UIViewRepresentable {

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        return
    }

}
