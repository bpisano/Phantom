//
//  PhantomTypeMacros.swift
//  PhantomType
//
//  Created by Benjamin Pisano on 15/12/2025.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

// PhantomPropertyMacro - marker macro that does nothing
public struct PhantomPropertyMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // This macro does nothing, it's just a marker
        return []
    }
}

public struct PhantomMacro: MemberAttributeMacro, MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        guard let varDecl = member.as(VariableDeclSyntax.self),
            let binding = varDecl.bindings.first
        else {
            return []
        }

        // Check if this member has @PhantomProperty macro
        let hasPhantomPropertyMacro = varDecl.attributes.contains(where: { element in
            guard case .attribute(let attr) = element,
                let identifierType = attr.attributeName.as(IdentifierTypeSyntax.self)
            else {
                return false
            }
            return identifierType.name.text == "PhantomProperty"
        })

        guard hasPhantomPropertyMacro else {
            return []
        }

        // Must be a var, not let
        guard varDecl.bindingSpecifier.text == "var" else {
            throw MacroError.mustBeVar
        }

        // Get the parent type name
        guard let parentType = getParentTypeName(from: declaration) else {
            throw MacroError.parentTypeNotFound
        }

        // Get the property type
        guard let typeAnnotation = binding.typeAnnotation,
            let propertyType = typeAnnotation.type.as(IdentifierTypeSyntax.self)
        else {
            throw MacroError.propertyTypeNotFound
        }

        let propertyTypeName = propertyType.name.text

        // Create the PhantomWrapped attribute using proper syntax construction
        let propertyTypeArg = IdentifierTypeSyntax(name: .identifier(propertyTypeName))
        let parentTypeArg = IdentifierTypeSyntax(name: .identifier(parentType))

        let genericArguments = GenericArgumentListSyntax {
            GenericArgumentSyntax(argument: .type(TypeSyntax(propertyTypeArg)))
            GenericArgumentSyntax(argument: .type(TypeSyntax(parentTypeArg)))
        }

        let genericClause = GenericArgumentClauseSyntax(
            leftAngle: .leftAngleToken(),
            arguments: genericArguments,
            rightAngle: .rightAngleToken()
        )

        let attributeName = IdentifierTypeSyntax(
            name: .identifier("PhantomWrapped"),
            genericArgumentClause: genericClause
        )

        let attribute = AttributeSyntax(
            atSign: .atSignToken(),
            attributeName: attributeName
        )

        return [attribute]
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Get the parent type name
        guard let parentType = getParentTypeName(from: declaration) else {
            throw MacroError.parentTypeNotFound
        }

        // Find the property with @PhantomProperty macro
        guard
            let varDecl = declaration.memberBlock.members.first(where: { member in
                guard let varDecl = member.decl.as(VariableDeclSyntax.self) else {
                    return false
                }

                // Check for @PhantomProperty macro
                return varDecl.attributes.contains(where: { element in
                    guard case .attribute(let attr) = element,
                        let identifierType = attr.attributeName.as(IdentifierTypeSyntax.self)
                    else {
                        return false
                    }
                    return identifierType.name.text == "PhantomProperty"
                })
            })?.decl.as(VariableDeclSyntax.self)
        else {
            throw MacroError.phantomPropertyNotFound
        }

        // Get the property name and type
        guard let binding = varDecl.bindings.first,
            let pattern = binding.pattern.as(IdentifierPatternSyntax.self),
            let typeAnnotation = binding.typeAnnotation,
            let propertyType = typeAnnotation.type.as(IdentifierTypeSyntax.self)
        else {
            throw MacroError.propertyTypeNotFound
        }

        let propertyName = pattern.identifier.text
        let propertyTypeName = propertyType.name.text

        // Get custom typealias name or use capitalized property name
        let typealiasName: String
        if let customName = extractCustomTypealiasName(from: varDecl) {
            typealiasName = customName
        } else {
            // Capitalize the property name for the typealias
            typealiasName = propertyName.prefix(1).uppercased() + propertyName.dropFirst()
        }

        // Check if the declaration has a public access modifier
        let isPublic = declaration.modifiers.contains { modifier in
            modifier.name.text == "public"
        }

        // Create the typealias with optional public modifier
        let accessModifier: String = isPublic ? "public " : ""
        let typealiasDecl = try TypeAliasDeclSyntax(
            "\(raw: accessModifier)typealias \(raw: typealiasName) = PhantomType<\(raw: propertyTypeName), \(raw: parentType)>"
        )

        return [DeclSyntax(typealiasDecl)]
    }

    private static func extractCustomTypealiasName(from varDecl: VariableDeclSyntax) -> String? {
        // Look for @PhantomProperty attribute with a custom name argument
        for attribute in varDecl.attributes {
            guard case .attribute(let attr) = attribute,
                let identifierType = attr.attributeName.as(IdentifierTypeSyntax.self),
                identifierType.name.text == "PhantomProperty",
                let arguments = attr.arguments,
                case .argumentList(let list) = arguments,
                let firstArg = list.first,
                let stringLiteral = firstArg.expression.as(StringLiteralExprSyntax.self),
                let segment = stringLiteral.segments.first,
                case .stringSegment(let stringSegment) = segment
            else {
                continue
            }
            return stringSegment.content.text
        }
        return nil
    }

    private static func getParentTypeName(from declaration: some DeclGroupSyntax) -> String? {
        if let structDecl = declaration.as(StructDeclSyntax.self) {
            return structDecl.name.text
        } else if let classDecl = declaration.as(ClassDeclSyntax.self) {
            return classDecl.name.text
        } else if let enumDecl = declaration.as(EnumDeclSyntax.self) {
            return enumDecl.name.text
        } else if let actorDecl = declaration.as(ActorDeclSyntax.self) {
            return actorDecl.name.text
        }
        return nil
    }
}

enum MacroError: Error, CustomStringConvertible {
    case parentTypeNotFound
    case propertyTypeNotFound
    case phantomPropertyNotFound
    case mustBeVar

    var description: String {
        switch self {
        case .parentTypeNotFound:
            return
                "@Phantom can only be applied to types (struct, class, enum, or actor)"
        case .propertyTypeNotFound:
            return
                "@Phantom requires the property marked with @PhantomProperty to have an explicit type annotation"
        case .phantomPropertyNotFound:
            return "@Phantom requires a property marked with @PhantomProperty in the type"
        case .mustBeVar:
            return
                "@Phantom requires the property marked with @PhantomProperty to be a var, not let"
        }
    }
}
