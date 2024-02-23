import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(MigratorMacros)
import MigratorMacros

let testMacros: [String: Macro.Type] = [
    "SemanticVersion": SemanticVersionMacro.self,
]
#endif

final class SemanticVersionMacroTests: XCTestCase {
    func testMacro() throws {
        #if canImport(MigratorMacros)
        assertMacroExpansion(
            """
            #SemanticVersion("1.0.1")
            """,
            expandedSource: """
            SemanticVersion("1.0.1")!
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroWithStringLiteral() throws {
        #if canImport(MigratorMacros)
        assertMacroExpansion(
            #"""
            #SemanticVersion("invalid")
            """#,
            expandedSource: #"""
            #SemanticVersion("invalid")
            """#,
            diagnostics: [
                DiagnosticSpec(message: #"""
                "invalid" is not a valid semantic version
                """#, line: 1, column: 1)
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
