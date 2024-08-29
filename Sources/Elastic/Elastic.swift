//
//  Elastic.swift
//
//
//  Created by Michael Hulet on 8/29/24.
//

import SwiftSyntaxMacros
import SwiftCompilerPlugin

/// Compiler plugins exported by the ``Elastic`` module
@main struct Plugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        NameOf.self,
    ]
}
