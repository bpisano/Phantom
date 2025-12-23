//
//  PhantomWrapped.swift
//  PhantomType
//
//  Created by Benjamin Pisano on 15/12/2025.
//

import Foundation

@propertyWrapper
public struct PhantomWrapped<Value, Container> {
    private var phantom: PhantomType<Value, Container>

    public var wrappedValue: Value {
        phantom.value
    }

    public var projectedValue: PhantomType<Value, Container> {
        phantom
    }

    public init(wrappedValue: Value) {
        self.phantom = .init(wrappedValue)
    }
}
