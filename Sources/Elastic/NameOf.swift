import SwiftCompilerPlugin
import SwiftSyntax
import SwiftDiagnostics
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Implementation of the `name(of:)` macro, which takes a metatype literal and produces its source-accurate name.
///
/// For example,
///
///     #name(of: NSObject.self)
///
/// will produce
///
///     "NSObject"
public struct NameOf: ExpressionMacro {
    public static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> ExprSyntax {
        
        guard let expression = node.arguments.first?.expression else {
            throw DiagnosticsError(diagnostics: [Diagnostic(node: node,
                                                            message: ExpansionErrorMessage.missingParameter,
                                                            fixIt: FixIt(message: ExpansionErrorFixItMessage.missingParameter,
                                                                         changes: [.replace(oldNode: Syntax(node.arguments),
                                                                                            newNode: Syntax(LabeledExprSyntax(label: "of",
                                                                                                                              expression: EditorPlaceholderExprSyntax(placeholder: "ExampleType.self"))))]))])
        }
        
        guard let access = expression.as(MemberAccessExprSyntax.self), let type = access.base, access.declName.baseName.trimmedDescription == TokenSyntax.keyword(.`self`).trimmedDescription else {
            throw DiagnosticsError(diagnostics: [Diagnostic(node: expression, message: ExpansionErrorMessage.nonTypeLiteral(expression: expression.description))])
        }
        
        let sourceNameKey = "sourceName"

        return #"(\#(raw: sourceNameKey): \#(literal: type.trimmedDescription), expression: \#(expression)).\#(raw: sourceNameKey)"# // Also include the expression to make sure the compiler recognizes it after the macro runs
    }
    
    /// Diagnostics generated in the expansion of the ``NameOf`` macro
    enum ExpansionErrorMessage: DiagnosticMessage {
        
        /// Diagnostic generated when the macro was not passed a parameter
        case missingParameter
        /**
         Diagnostic generated when the macro was passed a parameter that was not a type literal
         - Parameter expression: The source-accurate expression that was not a type literal
         */
        case nonTypeLiteral(expression: String)
        
        var message: String {
            get {
                switch self {
                    case .missingParameter:
                        return "Missing value for target metatype parameter"
                    case .nonTypeLiteral(let expression):
                        return "Expression \"\(expression)\" was not a type literal"
                }
            }
        }
        
        var diagnosticID: MessageID {
            get {
                let identifier = switch self {
                    case .missingParameter:
                        "missing-parameter"
                    case .nonTypeLiteral:
                        "non-type-literal"
                }
                
                return MessageID(domain: "tech.hulet.underware", id: identifier)
            }
        }
        
        var severity: DiagnosticSeverity {
            get {
                return .error
            }
        }
    }
    
    /// Fix-its corresponding to diagnostics generated while expanding the ``NameOf`` macro
    enum ExpansionErrorFixItMessage: FixItMessage {
        
        /// Fix-it suggesting the addition of the parameter that was missing
        case missingParameter
        
        var message: String {
            return switch self {
                case .missingParameter:
                    "Insert parameter \"of:\""
            }
        }
        
        var fixItID: MessageID {
            return switch self {
                case .missingParameter:
                    ExpansionErrorMessage.missingParameter.diagnosticID
            }
        }
    }
}
