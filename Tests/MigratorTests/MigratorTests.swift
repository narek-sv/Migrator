import XCTest
@testable import Migrator

final class MigratorTests: XCTestCase {
    var defaultTimeout = 1.5
    var defaultDelay = 0.1
    var migrator: Migrator!
    var storage: UserDefaults!
    var bundle: BundleMock!

    override func setUp() {
        storage = UserDefaults(suiteName: "test")
        storage.removePersistentDomain(forName: "test")

        bundle = BundleMock()
        bundle.versionString = "2.0.0"

        migrator = Migrator(storage: storage, bundle: bundle)
    }
    
    override func tearDown() {
        storage.removePersistentDomain(forName: "test")
    }
    
    func testInvalidAppVersions() async {
        // Given
        bundle.versionString = ""
        
        // When
        await migrator.registerTask(with: "test1", task: { })
        
        // Then
        do {
            _ = try await migrator.start()
        } catch let error as Migrator.SetupError {
            XCTAssertEqual(error, .invalidAppVersion)
        } catch {
            XCTFail("Unknown error")
        }
        
        // Given
        bundle.versionString = "abc"
        migrator = Migrator(storage: storage, bundle: bundle)
        
        // When
        await migrator.registerTask(with: "test2", task: { })
        
        // Then
        do {
            _ = try await migrator.start()
        } catch let error as Migrator.SetupError {
            XCTAssertEqual(error, .invalidAppVersion)
        } catch {
            XCTFail("Unknown error")
        }
        
        // Given
        bundle.versionString = "1.0.0"
        migrator = Migrator(storage: storage, bundle: bundle)
        
        // When
        await migrator.registerTask(with: "test3", task: { })
        
        // Then
        do {
            _ = try await migrator.start()
        } catch {
            XCTFail("Unexpected error")
        }
    }
    
    func testInvalidBounds() async {
        // Given
        bundle.versionString = "2.0.0"
        
        // When
        await migrator.registerTask(with: "test1",
                                    from: #SemanticVersion("3.0.0"),
                                    to: #SemanticVersion("1.0.0"),
                                    task: { })
        
        // Then
        do {
            _ = try await migrator.start()
        } catch let error as Migrator.SetupError {
            XCTAssertEqual(error, .invalidBounds)
        } catch {
            XCTFail("Unknown error")
        }
        
        // Given
        migrator = Migrator(storage: storage, bundle: bundle)

        // When
        await migrator.registerTask(with: "test1",
                                    from: #SemanticVersion("1.0.0"),
                                    to: #SemanticVersion("3.0.0"),
                                    task: { })
        
        // Then
        do {
            _ = try await migrator.start()
        } catch {
            XCTFail("Unexpected error")
        }
    }
    
    func testDuplicateTasks() async {
        // Given
        bundle.versionString = "2.0.0"
        
        // When
        await migrator.registerTask(with: "test1", task: { })
        await migrator.registerTask(with: "test1", task: { })
        
        // Then
        do {
            _ = try await migrator.start()
        } catch let error as Migrator.SetupError {
            XCTAssertEqual(error, .duplicateTask)
        } catch {
            XCTFail("Unknown error")
        }

    }
    
    func testAlreadyStarted() async {
        // When
        do {
            _ = try await migrator.start()
        } catch {
            XCTFail("Unexpected error")
        }
        
        // Then
        do {
            _ = try await migrator.start()
        } catch let error as Migrator.SetupError {
            XCTAssertEqual(error, .alreadyStarted)
        } catch {
            XCTFail("Unknown error")
        }
    }

    func testOutdatedBounds() async {
        // Given
        bundle.versionString = "2.0.0"
                
        // When
        await migrator.registerTask(with: "test1",
                                    from: #SemanticVersion("1.0.0"),
                                    to: #SemanticVersion("1.1.0"),
                                    task: { })
        
        // Then
        do {
            _ = try await migrator.start()
        } catch let error as Migrator.SetupError {
            XCTAssertEqual(error, .outdatedBounds)
        } catch {
            XCTFail("Unknown error")
        }
        
        // Given
        migrator = Migrator(storage: storage, bundle: bundle)

        // When
        await migrator.registerTask(with: "test1",
                                    from: #SemanticVersion("2.1.0"),
                                    to: #SemanticVersion("3.0.0"),
                                    task: { })
        
        // Then
        do {
            _ = try await migrator.start()
        } catch let error as Migrator.SetupError {
            XCTAssertEqual(error, .outdatedBounds)
        } catch {
            XCTFail("Unknown error")
        }
        
        // Given
        migrator = Migrator(storage: storage, bundle: bundle)

        // When
        await migrator.registerTask(with: "test1",
                                    from: #SemanticVersion("2.0.0"),
                                    to: #SemanticVersion("2.0.0"),
                                    task: { })
        
        // Then
        do {
            _ = try await migrator.start()
        } catch {
            XCTFail("Unexpected error")
        }
        
        // Given
        migrator = Migrator(storage: storage, bundle: bundle)

        // When
        await migrator.registerTask(with: "test1",
                                    from: #SemanticVersion("2.0.0"),
                                    to: #SemanticVersion("3.0.0"),
                                    task: { })
        
        // Then
        do {
            _ = try await migrator.start()
        } catch {
            XCTFail("Unexpected error")
        }
        
        // Given
        migrator = Migrator(storage: storage, bundle: bundle)

        // When
        await migrator.registerTask(with: "test1",
                                    from: #SemanticVersion("1.0.0"),
                                    to: #SemanticVersion("2.0.0"),
                                    task: { })
        
        // Then
        do {
            _ = try await migrator.start()
        } catch {
            XCTFail("Unexpected error")
        }
    }
    
    func testMaxAttempts() async {
        // Given
        bundle.versionString = "2.0.0"
                
        // When
        await migrator.registerTask(with: "test1",
                                    maxAttempts: 0,
                                    task: { })
        
        // Then
        do {
            _ = try await migrator.start()
        } catch let error as Migrator.SetupError {
            XCTAssertEqual(error, .invalidAttempts)
        } catch {
            XCTFail("Unknown error")
        }
        
        // Given
        migrator = Migrator(storage: storage, bundle: bundle)

        // When
        await migrator.registerTask(with: "test1",
                                    maxAttempts: -1,
                                    task: { })
        
        // Then
        do {
            _ = try await migrator.start()
        } catch let error as Migrator.SetupError {
            XCTAssertEqual(error, .invalidAttempts)
        } catch {
            XCTFail("Unknown error")
        }
        
        // Given
        migrator = Migrator(storage: storage, bundle: bundle)

        // When
        // When
        await migrator.registerTask(with: "test1",
                                    maxAttempts: 1,
                                    task: { })
        
        // Then
        do {
            _ = try await migrator.start()
        } catch {
            XCTFail("Unexpected error")
        }
    }
    
    func testStartErrorsCycle() async {
        // Given
        bundle.versionString = "2.0.0"
                
        // When
        await migrator.registerTask(with: "test1",
                                    dependencies: ["test1"],
                                    task: { })
        
        // Then
        do {
            _ = try await migrator.start()
        } catch let error as Migrator.SetupError {
            XCTAssertEqual(error, .dependencyCycle)
        } catch {
            XCTFail("Unknown error")
        }
    }
    
    func testStartErrorsDependency() async {
        // Given
        bundle.versionString = "2.0.0"
                
        // When
        await migrator.registerTask(with: "test1",
                                    dependencies: ["test2"],
                                    task: { })
        
        // Then
        do {
            _ = try await migrator.start()
        } catch let error as Migrator.SetupError {
            XCTAssertEqual(error, .invalidDependency)
        } catch {
            XCTFail("Unknown error")
        }
    }
    
    func testStartEmpty() async {
        // When
        do {
            let result = try await migrator.start()
            XCTAssertTrue(result.isEmpty)
        } catch {
            XCTFail("Unexpected error")
        }
    }
    
    func testStartDependant() async throws {
        // Given
        var task1Called = false
        var task2Called = false
        var task3Called = false

        // When
        await migrator.registerTask(with: "test1", dependencies: ["test2"]) {
            XCTAssertFalse(task1Called)
            XCTAssertTrue(task2Called)
            XCTAssertTrue(task3Called)
            task1Called = true
        }
        await migrator.registerTask(with: "test2", dependencies: ["test3"]) { 
            XCTAssertFalse(task1Called)
            XCTAssertFalse(task2Called)
            XCTAssertTrue(task3Called)
            task2Called = true
        }
        await migrator.registerTask(with: "test3") { 
            XCTAssertFalse(task1Called)
            XCTAssertFalse(task2Called)
            XCTAssertFalse(task3Called)
            task3Called = true
        }
        
        let results = try await migrator.start()
        let now = Date()

        // Then
        XCTAssertTrue(task1Called)
        XCTAssertTrue(task2Called)
        XCTAssertTrue(task3Called)
        XCTAssertEqual(results.count, 3)
        
        let status1 = results["test1"]!
        XCTAssertEqual(status1.failedAttempts, 0)
        XCTAssertEqual(status1.taskID, "test1")
        
        if case let .success(success) = status1.completionStatus {
            XCTAssertTrue(success.completionDate <= now)
        } else {
            XCTFail("Wrong status")
        }
        
        let status2 = results["test2"]!
        XCTAssertEqual(status2.failedAttempts, 0)
        XCTAssertEqual(status2.taskID, "test2")
        
        if case let .success(success) = status2.completionStatus {
            XCTAssertTrue(success.completionDate <= now)
        } else {
            XCTFail("Wrong status")
        }
        
        let status3 = results["test3"]!
        XCTAssertEqual(status3.failedAttempts, 0)
        XCTAssertEqual(status3.taskID, "test3")
        
        if case let .success(success) = status3.completionStatus {
            XCTAssertTrue(success.completionDate <= now)
        } else {
            XCTFail("Wrong status")
        }
    }
    
    func testStartError() async throws {
        // Given
        var task1Called = false
        var task2Called = false
        var task3Called = false

        // When
        await migrator.registerTask(with: "test1", dependencies: ["test2"]) {
            XCTAssertFalse(task1Called)
            XCTAssertTrue(task2Called)
            XCTAssertTrue(task3Called)
            task1Called = true
            throw NSError(message: "error")
        }
        await migrator.registerTask(with: "test2", dependencies: ["test3"]) {
            XCTAssertFalse(task1Called)
            XCTAssertFalse(task2Called)
            XCTAssertTrue(task3Called)
            task2Called = true
        }
        await migrator.registerTask(with: "test3") {
            XCTAssertFalse(task1Called)
            XCTAssertFalse(task2Called)
            XCTAssertFalse(task3Called)
            task3Called = true
        }
        
        let results = try await migrator.start()
        let now = Date()

        // Then
        XCTAssertTrue(task1Called)
        XCTAssertTrue(task2Called)
        XCTAssertTrue(task3Called)
        XCTAssertEqual(results.count, 3)
        
        let status1 = results["test1"]!
        XCTAssertEqual(status1.failedAttempts, 1)
        XCTAssertEqual(status1.taskID, "test1")
        
        if case let .failure(failure) = status1.completionStatus, case let .taskFailed(message) = failure.reason {
            XCTAssertTrue(failure.lastFailDate <= now)
            XCTAssertEqual(message, "error")
        } else {
            XCTFail("Wrong status")
        }
        
        let status2 = results["test2"]!
        XCTAssertEqual(status2.failedAttempts, 0)
        XCTAssertEqual(status2.taskID, "test2")
        
        if case let .success(success) = status2.completionStatus {
            XCTAssertTrue(success.completionDate <= now)
        } else {
            XCTFail("Wrong status")
        }
        
        let status3 = results["test3"]!
        XCTAssertEqual(status3.failedAttempts, 0)
        XCTAssertEqual(status3.taskID, "test3")
        
        if case let .success(success) = status3.completionStatus {
            XCTAssertTrue(success.completionDate <= now)
        } else {
            XCTFail("Wrong status")
        }
    }
        

    func testStartDependencyError() async throws {
        // When
        await migrator.registerTask(with: "test1", dependencies: ["test2"]) {
            XCTFail("should never be called")
        }
        await migrator.registerTask(with: "test2", dependencies: ["test3"]) {
            XCTFail("should never be called")
        }
        await migrator.registerTask(with: "test3") {
            throw NSError(message: "error")
        }
        
        let results = try await migrator.start()
        let now = Date()

        // Then
        XCTAssertEqual(results.count, 3)
        
        let status1 = results["test1"]!
        XCTAssertEqual(status1.failedAttempts, 0)
        XCTAssertEqual(status1.taskID, "test1")
        
        if case let .failure(failure) = status1.completionStatus, case .dependencyFailed = failure.reason {
            XCTAssertTrue(failure.lastFailDate <= now)
        } else {
            XCTFail("Wrong status")
        }
        
        let status2 = results["test2"]!
        XCTAssertEqual(status2.failedAttempts, 0)
        XCTAssertEqual(status2.taskID, "test2")
        
        if case let .failure(failure) = status1.completionStatus, case .dependencyFailed = failure.reason {
            XCTAssertTrue(failure.lastFailDate <= now)
        } else {
            XCTFail("Wrong status")
        }
        
        let status3 = results["test3"]!
        XCTAssertEqual(status3.failedAttempts, 1)
        XCTAssertEqual(status3.taskID, "test3")
        
        if case let .failure(failure) = status3.completionStatus, case let .taskFailed(message) = failure.reason {
            XCTAssertTrue(failure.lastFailDate <= now)
            XCTAssertEqual(message, "error")
        } else {
            XCTFail("Wrong status")
        }
    }
    
    func testStartExceedError() async throws {
        // Given
        var test1Called = false
        bundle.versionString = "2.0.0"
        
        // When
        await migrator.registerTask(with: "test1", task: { throw NSError(message: "error") })
        try await migrator.start()
        migrator = Migrator(storage: storage, bundle: bundle)
        await migrator.registerTask(with: "test1", task: { test1Called = true })
        
        let results = try await migrator.start()
        let now = Date()

        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertFalse(test1Called)
        
        let status1 = results["test1"]!
        XCTAssertEqual(status1.failedAttempts, 1)
        XCTAssertEqual(status1.taskID, "test1")
        
        if case let .failure(failure) = status1.completionStatus, case .exceededAttempts = failure.reason {
            XCTAssertTrue(failure.lastFailDate <= now)
        } else {
            XCTFail("Wrong status")
        }
    }
    
    
    func testStartExceedErrorBigger() async throws {
        // Given
        // Given
        var test1Called = false
        bundle.versionString = "2.0.0"
        
        // When
        await migrator.registerTask(with: "test1", task: { throw NSError(message: "error") })
        try await migrator.start()
        migrator = Migrator(storage: storage, bundle: bundle)
        await migrator.registerTask(with: "test1", maxAttempts: 2, task: { test1Called = true })
        
        let results = try await migrator.start()
        let now = Date()

        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertTrue(test1Called)
        
        let status1 = results["test1"]!
        XCTAssertEqual(status1.failedAttempts, 1)
        XCTAssertEqual(status1.taskID, "test1")
        
        if case let .success(success) = status1.completionStatus {
            XCTAssertTrue(success.completionDate <= now)
        } else {
            XCTFail("Wrong status")
        }
    }
}

private func NSError(message: String) -> NSError {
    NSError(domain: "domain", code: -3, userInfo: [NSLocalizedFailureErrorKey: message])
}

final class BundleMock: Bundle {
    var versionString: String = ""
    
    override var infoDictionary: [String : Any]? {
        ["CFBundleShortVersionString": versionString]
    }
}

