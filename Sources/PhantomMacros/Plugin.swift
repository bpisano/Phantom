//
//  File.swift
//  PhantomType
//
//  Created by Benjamin Pisano on 15/12/2025.
//

import Foundation
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct PhantomTypePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        PhantomMacro.self,
        PhantomPropertyMacro.self,
    ]
}
