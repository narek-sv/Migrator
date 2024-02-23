//
//  SemanticVersion.swift
//
//
//  Created by Narek Sahakyan on 23.02.24.
//

import Foundation

public typealias Version = SemanticVersion
public struct SemanticVersion {
    public let major: Int
    public let minor: Int
    public let patch: Int
    public let prereleaseIdentifiers: [String]
    public let buildMetadataIdentifiers: [String]
    
    public init(major: Int, minor: Int, patch: Int,
                prereleaseIdentifiers: [String] = [],
                buildMetadataIdentifiers: [String] = []) {
        self.major = major
        self.minor = minor
        self.patch = patch
        self.prereleaseIdentifiers = prereleaseIdentifiers
        self.buildMetadataIdentifiers = buildMetadataIdentifiers
    }
    
    public static func isPrerelease<S: StringProtocol>(string: S) -> Bool {
        isDigit(string: string) ? isNumeric(string: string) : isIdentifier(string: string)
    }
    
    public static func isNumeric<S: StringProtocol>(string: S) -> Bool {
        string.hasPrefix("0") ? string == "0" : isDigit(string: string)
    }
    
    public static func isIdentifier<S: StringProtocol>(string: S) -> Bool {
        !string.isEmpty && string.allSatisfy({ isIdentifier(character: $0) })
    }
    
    public static func isDigit<S: StringProtocol>(string: S) -> Bool {
        !string.isEmpty && string.allSatisfy({ isDigit(character: $0) })
    }
    
    public static func isIdentifier(character: Character) -> Bool {
        isDigit(character: character) || isNonDigit(character: character)
    }
    
    public static func isNonDigit(character: Character) -> Bool {
        character == "-" ? true : isLetter(character: character)
    }
    
    public static func isDigit(character: Character) -> Bool {
        String(character).range(of: "[0-9]", options: .regularExpression) != nil
    }
    
    public static func isLetter(character: Character) -> Bool {
        String(character).range(of: "[A-Za-z]", options: .regularExpression) != nil
    }
}

// MARK: - SemanticVersion

extension SemanticVersion: LosslessStringConvertible {
    public init?<S: StringProtocol>(_ string: S) {
        func identifiers(start: String.Index?, end: String.Index?) -> [String] {
            let end = end ?? string.endIndex
            guard let start = start, start <= end else { return [] }
            let identifiers = string[string.index(after: start)..<end]
            return identifiers
                .split(separator: ".")
                .map { .init($0) }
        }
        
        // Parsing
        let prereleaseStartIndex = string.firstIndex(of: "-")
        let metadataStartIndex = string.firstIndex(of: "+")
        let versioEndIndex = min(prereleaseStartIndex ?? string.endIndex, metadataStartIndex ?? string.endIndex)
        let version = string.prefix(upTo: versioEndIndex)
        let versionComponents = version.split(separator: ".", maxSplits: 2, omittingEmptySubsequences: false)
        let prerelease = identifiers(start: prereleaseStartIndex, end: metadataStartIndex)
        let metadata = identifiers(start: metadataStartIndex, end: string.endIndex)
        
        // Validation
        guard versionComponents.allSatisfy({ Self.isNumeric(string: $0) }) else { return nil }
        guard prerelease.allSatisfy({ Self.isPrerelease(string: $0) }) else { return nil }
        guard metadata.allSatisfy({ Self.isIdentifier(string: $0) }) else { return nil }
        
        // Initialization
        self.major = Int(versionComponents.element(at: 0) ?? "0")!
        self.minor = Int(versionComponents.element(at: 1) ?? "0")!
        self.patch = Int(versionComponents.element(at: 2) ?? "0")!
        self.prereleaseIdentifiers = prerelease
        self.buildMetadataIdentifiers = metadata
    }
    
    public var description: String {
        var base = "\(major).\(minor).\(patch)"
        
        if !prereleaseIdentifiers.isEmpty {
            base += "-" + prereleaseIdentifiers.joined(separator: ".")
        }
        
        if !buildMetadataIdentifiers.isEmpty {
            base += "+" + buildMetadataIdentifiers.joined(separator: ".")
        }
        
        return base
    }
}

// MARK: - Equatable

extension SemanticVersion: Equatable {
    public static func == (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        lhs.major == rhs.major &&
        lhs.minor == rhs.minor &&
        lhs.patch == rhs.patch &&
        lhs.prereleaseIdentifiers == rhs.prereleaseIdentifiers
    }
}

// MARK: - Comparable

extension SemanticVersion: Comparable {
    public static func < (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        let lhsComparators = [lhs.major, lhs.minor, lhs.patch]
        let rhsComparators = [rhs.major, rhs.minor, rhs.patch]
        
        guard lhsComparators == rhsComparators else { return lhsComparators.lexicographicallyPrecedes(rhsComparators) }
        guard lhs.prereleaseIdentifiers.count > 0 else { return false }
        guard rhs.prereleaseIdentifiers.count > 0 else { return true }
        
        let zipped = zip(lhs.prereleaseIdentifiers, rhs.prereleaseIdentifiers)
        for (lhsPrerelease, rhsPrerelease) in zipped where lhsPrerelease != rhsPrerelease {
            switch (Int(lhsPrerelease), Int(rhsPrerelease)) {
            case let (.some(lhsInt), .some(rhsInt)):    return lhsInt < rhsInt
            case (.none, .none):                        return lhsPrerelease < rhsPrerelease
            case (.some, .none):                        return true
            case (.none, .some):                        return false
            }
        }
        
        return lhs.prereleaseIdentifiers.count < rhs.prereleaseIdentifiers.count
    }
}

// MARK: - Hashable

extension SemanticVersion: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(major)
        hasher.combine(minor)
        hasher.combine(patch)
        hasher.combine(prereleaseIdentifiers)
    }
}

// MARK: - Codable

extension SemanticVersion: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        
        if let version = Self.init(string) {
            self = version
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid semantic version")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
}

// MARK: - For Convenience

public extension SemanticVersion {
    static var oldest: SemanticVersion {
        SemanticVersion(major: .min,
                        minor: .min,
                        patch: .min,
                        prereleaseIdentifiers: [],
                        buildMetadataIdentifiers: [])
    }
    
    static var newest: SemanticVersion {
        SemanticVersion(major: .max,
                        minor: .max,
                        patch: .max,
                        prereleaseIdentifiers: [],
                        buildMetadataIdentifiers: [])
    }
}

public extension Bundle {
    var semanticVersion: SemanticVersion? {
        guard let versionString = infoDictionary?["CFBundleShortVersionString"] as? String else { return nil }
        return SemanticVersion(versionString)
    }
}

public extension ProcessInfo {
    var operatingSystemSemanticVersion: SemanticVersion {
        let version = operatingSystemVersion
        return SemanticVersion(major: version.majorVersion,
                               minor: version.minorVersion,
                               patch: version.patchVersion,
                               prereleaseIdentifiers: [],
                               buildMetadataIdentifiers: [])
    }
}

// MARK: - Helpers

fileprivate extension Collection {
    func element(at index: Index) -> Element? {
        if indices.contains(index) {
            return self[index]
        }
        
        return nil
    }
}
