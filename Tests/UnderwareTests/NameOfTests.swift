import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(Elastic)
@testable import Elastic
#endif

final class NameOfTests: XCTestCase {
    
    // Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
    #if canImport(Elastic)
    static let macroName = "nameOf"
    private let testMacros: [String: Macro.Type] = [
        macroName: NameOf.self,
    ]
    #endif
    
    func testProducesTypeCheckedName() throws {
        #if canImport(Elastic)
        assertMacroExpansion(
            """
            #\(Self.macroName)(NameOfTests.self)
            """,
            expandedSource: #"""
            (sourceName: "NameOfTests", expression: NameOfTests.self).sourceName
            """#,
            macros: testMacros
        )
        #else
        throw XCTSkip("Macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testThrowsErrorForNonTypeParameters() throws {
        #if canImport(Elastic)
        let failingValue = "1"
        let source = """
            #\(Self.macroName)(\(failingValue))
            """
        let expectedError = NameOf.ExpansionErrorMessage.nonTypeLiteral(expression: "1")
        
        assertMacroExpansion(
            source,
            expandedSource: source,
            diagnostics: [DiagnosticSpec(id: expectedError.diagnosticID,
                                         message: expectedError.message,
                                         line: 1,
                                         column: Self.macroName.count + 2 + 1, // + 2 for the macro name and the # and (, and then + 1 for the next column
                                         severity: .error)],
            macros: testMacros
        )
        #else
        throw XCTSkip("Macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testThrowsErrorForMissingParameter() throws {
        #if canImport(Elastic)
        let source = """
            #\(Self.macroName)()
            """
        let expectedError = NameOf.ExpansionErrorMessage.missingParameter
        
        assertMacroExpansion(
            source,
            expandedSource: source,
            diagnostics: [DiagnosticSpec(id: expectedError.diagnosticID,
                                         message: expectedError.message,
                                         line: 1,
                                         column: 1,
                                         severity: .error,
                                         fixIts: [FixItSpec(message: NameOf.ExpansionErrorFixItMessage.missingParameter.message)])],
            macros: testMacros
        )
        #else
        throw XCTSkip("Macros are only supported when running tests for the host platform")
        #endif
    }
}
