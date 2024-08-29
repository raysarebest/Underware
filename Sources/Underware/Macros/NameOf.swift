//
//  NameOf.swift
//  
//
//  Created by Michael Hulet on 8/21/24.
//

/// Finds the source-accurate name of the given type
///
/// For example,
///
///     #name(of: NSObject.self)
///
/// produces the String `"NSObject"` when `NSObject` is available in the current context.
@freestanding(expression) public macro name<Metatype>(of type: Metatype) -> String = #externalMacro(module: "Elastic", type: "NameOf")
