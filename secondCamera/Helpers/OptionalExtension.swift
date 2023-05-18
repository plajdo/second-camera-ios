//
//  OptionalExtension.swift
//  secondCamera
//
//  Created by Filip Šašala on 18/05/2023.
//

import Foundation

extension Optional {

    @inlinable var isNil: Bool {
        get { self == nil }
        set {}
    }

    @inlinable var isNotNil: Bool {
        get { !isNil }
        set {}
    }

}
