// The Swift Programming Language
// https://docs.swift.org/swift-book
@_exported import MigratorCore

/// A macro that produces an unwrapped SemanticVersion in case of a valid input string.
/// For example,
///
///     #SemanticVersion("1.0.0")
///
/// produces an unwrapped `SemanticVersion` if the sting is valid. Otherwise, it emits a compile-time error.
@freestanding(expression)
public macro SemanticVersion(_ stringLiteral: String) -> SemanticVersion = 
#externalMacro(module: "MigratorMacros", type: "SemanticVersionMacro")
