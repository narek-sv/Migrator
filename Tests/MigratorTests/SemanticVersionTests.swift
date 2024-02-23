import XCTest
@testable import MigratorCore

final class SemanticVersionTests: XCTestCase {
    
    func testStaticMethods() {
        XCTAssertTrue (SemanticVersion.isLetter(character: "a"))
        XCTAssertTrue (SemanticVersion.isLetter(character: "z"))
        XCTAssertTrue (SemanticVersion.isLetter(character: "B"))
        XCTAssertTrue (SemanticVersion.isLetter(character: "X"))
        XCTAssertFalse(SemanticVersion.isLetter(character: "-"))
        XCTAssertFalse(SemanticVersion.isLetter(character: "1"))
        XCTAssertFalse(SemanticVersion.isLetter(character: "я"))
        XCTAssertFalse(SemanticVersion.isLetter(character: "ϴ"))

        XCTAssertTrue (SemanticVersion.isDigit(character: "0"))
        XCTAssertTrue (SemanticVersion.isDigit(character: "1"))
        XCTAssertTrue (SemanticVersion.isDigit(character: "9"))
        XCTAssertFalse(SemanticVersion.isDigit(character: "-"))
        XCTAssertFalse(SemanticVersion.isDigit(character: "⅚"))
        XCTAssertFalse(SemanticVersion.isDigit(character: "㊈"))
        XCTAssertFalse(SemanticVersion.isDigit(character: "ϴ"))
        XCTAssertFalse(SemanticVersion.isDigit(character: "z"))
        XCTAssertFalse(SemanticVersion.isDigit(character: "B"))
        
        XCTAssertTrue (SemanticVersion.isNonDigit(character: "z"))
        XCTAssertTrue (SemanticVersion.isNonDigit(character: "B"))
        XCTAssertTrue (SemanticVersion.isNonDigit(character: "-"))
        XCTAssertFalse(SemanticVersion.isNonDigit(character: "0"))
        XCTAssertFalse(SemanticVersion.isNonDigit(character: "9"))
        XCTAssertFalse(SemanticVersion.isNonDigit(character: "⅚"))
        XCTAssertFalse(SemanticVersion.isNonDigit(character: "㊈"))
        XCTAssertFalse(SemanticVersion.isNonDigit(character: "ϴ"))

        XCTAssertTrue (SemanticVersion.isIdentifier(character: "z"))
        XCTAssertTrue (SemanticVersion.isIdentifier(character: "B"))
        XCTAssertTrue (SemanticVersion.isIdentifier(character: "-"))
        XCTAssertTrue (SemanticVersion.isIdentifier(character: "0"))
        XCTAssertTrue (SemanticVersion.isIdentifier(character: "9"))
        XCTAssertFalse(SemanticVersion.isIdentifier(character: "⅚"))
        XCTAssertFalse(SemanticVersion.isIdentifier(character: "㊈"))
        XCTAssertFalse(SemanticVersion.isIdentifier(character: "ϴ"))
        
        XCTAssertTrue (SemanticVersion.isDigit(string: "123"))
        XCTAssertTrue (SemanticVersion.isDigit(string: "0"))
        XCTAssertTrue (SemanticVersion.isDigit(string: "01"))
        XCTAssertFalse(SemanticVersion.isDigit(string: ""))
        XCTAssertFalse(SemanticVersion.isDigit(string: "⅚"))
        XCTAssertFalse(SemanticVersion.isDigit(string: "asd3"))
        XCTAssertFalse(SemanticVersion.isDigit(string: "-1243"))
        XCTAssertFalse(SemanticVersion.isDigit(string: "1245⅚"))
        
        XCTAssertTrue (SemanticVersion.isIdentifier(string: "123"))
        XCTAssertTrue (SemanticVersion.isIdentifier(string: "0"))
        XCTAssertTrue (SemanticVersion.isIdentifier(string: "-1243"))
        XCTAssertTrue (SemanticVersion.isIdentifier(string: "01"))
        XCTAssertTrue (SemanticVersion.isIdentifier(string: "0xFF"))
        XCTAssertTrue (SemanticVersion.isIdentifier(string: "asd3"))
        XCTAssertTrue (SemanticVersion.isIdentifier(string: "V-3"))
        XCTAssertFalse(SemanticVersion.isIdentifier(string: ""))
        XCTAssertFalse(SemanticVersion.isIdentifier(string: "⅚"))
        XCTAssertFalse(SemanticVersion.isIdentifier(string: "1245⅚"))

        XCTAssertTrue (SemanticVersion.isNumeric(string: "123"))
        XCTAssertTrue (SemanticVersion.isNumeric(string: "0"))
        XCTAssertFalse(SemanticVersion.isNumeric(string: "-1243"))
        XCTAssertFalse(SemanticVersion.isNumeric(string: "01"))
        XCTAssertFalse(SemanticVersion.isNumeric(string: "0xFF"))
        XCTAssertFalse(SemanticVersion.isNumeric(string: "asd3"))
        XCTAssertFalse(SemanticVersion.isNumeric(string: "V-3"))
        XCTAssertFalse(SemanticVersion.isNumeric(string: ""))
        XCTAssertFalse(SemanticVersion.isNumeric(string: "⅚"))
        XCTAssertFalse(SemanticVersion.isNumeric(string: "1245⅚"))
        
        XCTAssertTrue (SemanticVersion.isPrerelease(string: "V-3"))
        XCTAssertTrue (SemanticVersion.isPrerelease(string: "-1243"))
        XCTAssertTrue (SemanticVersion.isPrerelease(string: "asd3"))
        XCTAssertTrue (SemanticVersion.isPrerelease(string: "123"))
        XCTAssertTrue (SemanticVersion.isPrerelease(string: "0"))
        XCTAssertTrue (SemanticVersion.isPrerelease(string: "0xFF"))
        XCTAssertFalse(SemanticVersion.isPrerelease(string: "01"))
        XCTAssertFalse(SemanticVersion.isPrerelease(string: ""))
        XCTAssertFalse(SemanticVersion.isPrerelease(string: "⅚"))
        XCTAssertFalse(SemanticVersion.isPrerelease(string: "1245⅚"))
    }
    
    func testInit() {
        XCTAssertNil    (SemanticVersion(""))
        XCTAssertNotNil (SemanticVersion("2"))
        XCTAssertNil    (SemanticVersion("-2"))
        XCTAssertNil    (SemanticVersion("2."))
        XCTAssertNotNil (SemanticVersion("2.3"))
        XCTAssertNil    (SemanticVersion("2.-3"))
        XCTAssertNil    (SemanticVersion("2.3."))
        XCTAssertNotNil (SemanticVersion("2.3.4"))
        XCTAssertNil    (SemanticVersion("2.3.-4"))
        XCTAssertNil    (SemanticVersion("2.3.4."))
        XCTAssertNil    (SemanticVersion("2.3.4.5"))
        
        XCTAssertNotNil (SemanticVersion("2.0.0"))
        XCTAssertNil    (SemanticVersion("a.0.0"))
        XCTAssertNil    (SemanticVersion("02.0.0"))
        XCTAssertNotNil (SemanticVersion("2.2.0"))
        XCTAssertNil    (SemanticVersion("2.a.0"))
        XCTAssertNil    (SemanticVersion("2.02.0"))
        XCTAssertNotNil (SemanticVersion("2.2.2"))
        XCTAssertNil    (SemanticVersion("2.2.02"))
        XCTAssertNil    (SemanticVersion("2.2.a"))
        
        XCTAssertNotNil (SemanticVersion("2.0.0-"))
        XCTAssertNotNil (SemanticVersion("2.0.0-a"))
        XCTAssertNotNil (SemanticVersion("2.0.0-0"))
        XCTAssertNotNil (SemanticVersion("2.0.0-0.2"))
        XCTAssertNotNil (SemanticVersion("2.0.0-0.alpha-1"))
        XCTAssertNotNil (SemanticVersion("2.0.0-0a.alpha-1"))
        XCTAssertNil    (SemanticVersion("2.0.0-01.alpha-1"))
        XCTAssertNotNil (SemanticVersion("1.0.0-x-y-z.-."))
        XCTAssertNotNil (SemanticVersion("2.0.0+"))
        XCTAssertNotNil (SemanticVersion("2.0.0+a"))
        XCTAssertNotNil (SemanticVersion("2.0.0+0"))
        XCTAssertNotNil (SemanticVersion("2.0.0+0.2"))
        XCTAssertNotNil (SemanticVersion("2.0.0+0.alpha-1"))
        XCTAssertNotNil (SemanticVersion("2.0.0-0.alpha+1"))
        XCTAssertNil    (SemanticVersion("2.0.0-0.alpha+;"))
    }
    
    func testProperties() {
        var version = SemanticVersion("2")!
        XCTAssertEqual(version.major, 2)
        XCTAssertEqual(version.minor, 0)
        XCTAssertEqual(version.patch, 0)
        XCTAssertEqual(version.prereleaseIdentifiers, [])
        XCTAssertEqual(version.buildMetadataIdentifiers, [])

        version = SemanticVersion("2.3")!
        XCTAssertEqual(version.major, 2)
        XCTAssertEqual(version.minor, 3)
        XCTAssertEqual(version.patch, 0)
        XCTAssertEqual(version.prereleaseIdentifiers, [])
        XCTAssertEqual(version.buildMetadataIdentifiers, [])
        
        version = SemanticVersion("2.3.4")!
        XCTAssertEqual(version.major, 2)
        XCTAssertEqual(version.minor, 3)
        XCTAssertEqual(version.patch, 4)
        XCTAssertEqual(version.prereleaseIdentifiers, [])
        XCTAssertEqual(version.buildMetadataIdentifiers, [])
        
        version = SemanticVersion("2.3.4-")!
        XCTAssertEqual(version.major, 2)
        XCTAssertEqual(version.minor, 3)
        XCTAssertEqual(version.patch, 4)
        XCTAssertEqual(version.prereleaseIdentifiers, [])
        XCTAssertEqual(version.buildMetadataIdentifiers, [])
        
        version = SemanticVersion("2.3.4-asd.das-324.422")!
        XCTAssertEqual(version.major, 2)
        XCTAssertEqual(version.minor, 3)
        XCTAssertEqual(version.patch, 4)
        XCTAssertEqual(version.prereleaseIdentifiers, ["asd", "das-324", "422"])
        XCTAssertEqual(version.buildMetadataIdentifiers, [])
        
        version = SemanticVersion("2.3.4+0biuwwd-fdsml.dsfo")!
        XCTAssertEqual(version.major, 2)
        XCTAssertEqual(version.minor, 3)
        XCTAssertEqual(version.patch, 4)
        XCTAssertEqual(version.prereleaseIdentifiers, [])
        XCTAssertEqual(version.buildMetadataIdentifiers, ["0biuwwd-fdsml", "dsfo"])
        
        version = SemanticVersion("2.3.4-asd.das-324.422+0biuwwd-fdsml.dsfo")!
        XCTAssertEqual(version.major, 2)
        XCTAssertEqual(version.minor, 3)
        XCTAssertEqual(version.patch, 4)
        XCTAssertEqual(version.prereleaseIdentifiers, ["asd", "das-324", "422"])
        XCTAssertEqual(version.buildMetadataIdentifiers, ["0biuwwd-fdsml", "dsfo"])
    }
    
    func testDescription() {
        var version = SemanticVersion("2")!
        XCTAssertEqual(version.description, "2.0.0")

        version = SemanticVersion("2.3")!
        XCTAssertEqual(version.description, "2.3.0")
        
        version = SemanticVersion("2.3.4")!
        XCTAssertEqual(version.description, "2.3.4")
        
        version = SemanticVersion("2.3.4-")!
        XCTAssertEqual(version.description, "2.3.4")
        
        version = SemanticVersion("2.3.4-asd.das-324.422")!
        XCTAssertEqual(version.description, "2.3.4-asd.das-324.422")
        
        version = SemanticVersion("2.3.4+0biuwwd-fdsml.dsfo")!
        XCTAssertEqual(version.description, "2.3.4+0biuwwd-fdsml.dsfo")
        
        version = SemanticVersion("2.3.4-asd.das-324.422+0biuwwd-fdsml.dsfo.")!
        XCTAssertEqual(version.description, "2.3.4-asd.das-324.422+0biuwwd-fdsml.dsfo")
    }
    
    func testEquality() {
        XCTAssertEqual(SemanticVersion("2.0.0"), SemanticVersion("2.0.0"))
        XCTAssertNotEqual(SemanticVersion("2.0.0"), SemanticVersion("3.0.0"))
        XCTAssertNotEqual(SemanticVersion("2.0.0"), SemanticVersion("2.1.0"))
        XCTAssertNotEqual(SemanticVersion("2.0.0"), SemanticVersion("2.0.1"))

        XCTAssertEqual(SemanticVersion("2.0.0"), SemanticVersion("2.0.0-"))
        XCTAssertNotEqual(SemanticVersion("2.0.0"), SemanticVersion("2.0.0-alpha"))
        XCTAssertNotEqual(SemanticVersion("2.0.0-a"), SemanticVersion("2.0.0-alpha"))
        XCTAssertEqual(SemanticVersion("2.0.0-alpha"), SemanticVersion("2.0.0-alpha"))

        XCTAssertEqual(SemanticVersion("2.0.0+"), SemanticVersion("2.0.0"))
        XCTAssertEqual(SemanticVersion("2.0.0"), SemanticVersion("2.0.0+alpha"))
        XCTAssertEqual(SemanticVersion("2.0.0+alpha"), SemanticVersion("2.0.0+beta"))
    }
    
    func testComparisions() {
        XCTAssertTrue(SemanticVersion("1.0.0-alpha")! < SemanticVersion("1.0.0-alpha.1")!)
        XCTAssertTrue(SemanticVersion("1.0.0-alpha.1")! < SemanticVersion("1.0.0-alpha.beta")!)
        XCTAssertTrue(SemanticVersion("1.0.0-alpha.beta")! < SemanticVersion("1.0.0-beta")!)
        XCTAssertTrue(SemanticVersion("1.0.0-beta")! < SemanticVersion("1.0.0-beta.2")!)
        XCTAssertTrue(SemanticVersion("1.0.0-beta.2")! < SemanticVersion("1.0.0-beta.11")!)
        XCTAssertTrue(SemanticVersion("1.0.0-beta.11")! < SemanticVersion("1.0.0-rc.1")!)
        XCTAssertTrue(SemanticVersion("1.0.0-rc.1")! < SemanticVersion("1.0.0")!)
        XCTAssertTrue(SemanticVersion("1.0.0")! < SemanticVersion("1.0.1")!)
        XCTAssertTrue(SemanticVersion("1.0.1")! < SemanticVersion("1.1.0")!)
        XCTAssertTrue(SemanticVersion("1.1.0")! < SemanticVersion("1.1.10")!)
        XCTAssertTrue(SemanticVersion("1.1.1")! < SemanticVersion("2.0.0-alpha")!)
        XCTAssertTrue(SemanticVersion("1.1.1")! < SemanticVersion("2.0.0")!)
        XCTAssertTrue(SemanticVersion("1.8.1")! < SemanticVersion("1.20.0")!)

        XCTAssertFalse(SemanticVersion("1.1.2")! < SemanticVersion("1.1.2-1")!)
        XCTAssertFalse(SemanticVersion("1.1.1-a")! < SemanticVersion("1.1.1-1")!)
    }
    
    func testDecoding() {
        func toJSON(from version: String) -> Data {
            return "{\"version\":\"\(version)\"}".data(using: .utf8)!
        }
        
        // Given
        let decoder = JSONDecoder()
        // When
        let decoded = try! decoder.decode([String: SemanticVersion].self, from: toJSON(from: "1.3.6-a+b"))
        // Then
        XCTAssertEqual(SemanticVersion(major: 1, minor: 3, patch: 6,
                                       prereleaseIdentifiers: ["a"], buildMetadataIdentifiers: ["b"]), decoded["version"])
        XCTAssertThrowsError(try decoder.decode([String: SemanticVersion].self, from: toJSON(from: "1.3.06")))
    }
    
    func testEncode() {
        func toString(from data: Data) -> String {
            let dict = try! JSONSerialization.jsonObject(with: data, options: .allowFragments)
            return (dict as! [String: String])["version"]!
        }
        
        // Given
        let encoder = JSONEncoder()
        // When
        let data = try! encoder.encode(["version": SemanticVersion(major: 1, minor: 3, patch: 6,
                                       prereleaseIdentifiers: ["a"], buildMetadataIdentifiers: ["b"])])
        // Then
        XCTAssertEqual("1.3.6-a+b", toString(from: data))
    }
}
