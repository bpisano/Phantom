//
//  PhantomMacro.swift
//  PhantomType
//
//  Created by Benjamin Pisano on 15/12/2025.
//

import Foundation

/// A macro that transforms a property marked with @PhantomProperty into a phantom type property.
///
/// Note: The referenced property must be a `var`, not a `let`.
/// The property wrapper handles immutability.
///
/// Expands to:
/// ```swift
/// typealias PropertyName = PhantomType<PropertyType, ContainerType>
/// @PhantomWrapped<PropertyType, ContainerType>
/// var propertyName: PropertyType
/// ```
///
/// Example:
/// ```swift
/// @Phantom
/// struct Person {
///     @PhantomProperty
///     var id: UUID
/// }
/// // Generates: typealias Id = PhantomType<UUID, Person>
/// ```
@attached(memberAttribute)
@attached(member, names: arbitrary)
public macro Phantom() =
    #externalMacro(
        module: "PhantomTypeMacros",
        type: "PhantomMacro"
    )
