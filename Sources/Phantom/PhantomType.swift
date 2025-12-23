//
//  File.swift
//  PhantomType
//
//  Created by Benjamin Pisano on 15/12/2025.
//

import Foundation

public struct PhantomType<Value, PhantomType> {
    public let value: Value

    public init(_ value: Value) {
        self.value = value
    }
}
