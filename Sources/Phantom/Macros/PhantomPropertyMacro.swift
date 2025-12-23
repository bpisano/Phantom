//
//  PhantomPropertyMacro.swift
//  PhantomType
//
//  Created by Benjamin Pisano on 15/12/2025.
//

import Foundation

/// A marker macro that indicates which property should be used as the phantom ID.
///
/// This macro does nothing by itself but serves as a hint for the `@Phantom` macro
/// to identify which property to transform into a phantom type.
///
/// Example:
/// ```swift
/// @Phantom
/// struct Person {
///     @PhantomProperty
///     var identifier: UUID
/// }
/// ```
///
/// You can optionally specify a custom typealias name:
/// ```swift
/// @Phantom
/// struct Person {
///     // Generates: typealias PersonID = PhantomType<UUID, Person>
///
///     @PhantomProperty("PersonID")
///     var id: UUID
/// }
/// ```
@attached(peer)
public macro PhantomProperty(_ typealiasName: String? = nil) =
    #externalMacro(module: "PhantomTypeMacros", type: "PhantomPropertyMacro")
