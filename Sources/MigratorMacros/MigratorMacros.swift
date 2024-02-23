import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import MigratorCore

public struct SemanticVersionMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard let argument = node.argumentList.first?.expression,
              let segments = argument.as(StringLiteralExprSyntax.self)?.segments,
              segments.count == 1,
              case .stringSegment(let literalSegment)? = segments.first else {
            throw SemanticVersionMacroError.requiresStaticStringLiteral
        }

        guard let _ = SemanticVersion(literalSegment.content.text) else {
            throw SemanticVersionMacroError.malformedVersion(versionString: "\(argument)")
        }

        return "SemanticVersion(\(argument))!"
    }
}

enum SemanticVersionMacroError: Error, CustomStringConvertible {
    case requiresStaticStringLiteral
    case malformedVersion(versionString: String)

    var description: String {
        switch self {
        case .requiresStaticStringLiteral:
            return "#SemanticVersion requires a static string literal"
        case .malformedVersion(let versionString):
            return "\(versionString) is not a valid semantic version"
        }
    }
}

@main
struct SemanticVersionPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        SemanticVersionMacro.self,
    ]
}
