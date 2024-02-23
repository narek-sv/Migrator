# Migrator

Migrator is a versatile Swift Package designed to streamline the execution of asynchronous tasks with dependency management on all Apple platforms. It provides a robust solution for orchestrating tasks with complex dependencies, ensuring that each task is executed in the correct order, respecting the dependencies defined between them. With built-in error handling and retry capabilities, it significantly simplifies error recovery and enhances the reliability of task execution processes.

## Features
* **Dependency Management:** Define clear dependencies between asynchronous tasks to guarantee their correct execution sequence.
* **Error Handling:** Advanced error handling strategies enable graceful error recovery, ensuring task flow continuity.
* **Retry Capability:** Offers the ability to retry failed tasks in future app sessions, enhancing the resilience of your task management workflow.
* **Cross-Platform Compatibility:** Fully compatible with iOS, macOS, watchOS, and tvOS, facilitating a unified task management solution across all Apple platforms.
* **Unit Testing:** Extensively covered with unit tests to ensure high reliability and ease of maintenance.
* **App Version-Specific Tasks:** Uniquely allows bounding tasks within specific app versions or version ranges, making it ideal for version-specific migrations or one-time tasks.
* **User-Friendly API:** Designed with ease of integration in mind, making it suitable for a wide range of applications, from simple to complex migration tasks.
* **Semantic Versioning Support:** Includes a struct for describing, parsing, and manipulating semantic versions ([SemVer 2.0.0](https://semver.org/)), enabling precise version control.
* **Compile-Time Version Checks:** Utilizes a *Swift macro* for compile-time validation of semantic version strings, integrating directly with Xcode to display errors for invalid versions.

## Use Cases
* **Version-Specific Migrations:** Perfect for executing one-time migrations or updates when transitioning between app versions.
* **Data Management:** Ideal for data migrations, updates, and integrity checks during app upgrades.
* **Resource Management:** Efficiently preload necessary resources or perform cleanup tasks specific to app versions before startup.
* **Enhanced Version Integrity:** Leverage semantic versioning support to maintain version consistency and prevent compatibility issues across application updates.

## Semantic Version 2.0.0 and Swift Macro

A standout feature of the Package is its integrated support for Semantic Versioning ([SemVer 2.0.0](https://semver.org/)). This functionality is encapsulated within a dedicated struct that allows you to describe, parse, compare and manipulate version numbers. The Package introduces a compile-time check through a `Swift macro`, enabling to validate semantic version strings directly within the Xcode environment which prevents common versioning errors before runtime.

```swift
let version1 = SemanticVersion("1.0.1")
let version2 = SemanticVersion("2.0.0-0.alpha-1")

if let version1, let version2 {
    print(version1.major)
    print(version1.minor)
    print(version1.patch)
    print(version1.prereleaseIdentifiers)
    print(version1.buildMetadataIdentifiers)
            
    print(version1 > version2)
}
```

or use corressponding Swift Macro to do compile time version validation

<img width="719" alt="Screenshot 2024-02-23 at 23 03 47" src="https://github.com/narek-sv/Migrator/assets/23353201/b25dbc55-ab5b-406d-8077-999adf57f6dc">

## Getting Started

```swift
// Create the migrator
let migrator = Migrator()

// Then register all the tasks, providing a unique task ID, an optional app version range for execution, any dependencies on other tasks, and the number of retry attempts for the next app session in case of failure.
        
await migrator.registerTask(with: "task1",
                            from: #SemanticVersion("1.0.0"),
                            to: #SemanticVersion("3.0.0"),
                            dependencies: ["task2"],
                            task: { /* do any async throwing work something */ })
        
await migrator.registerTask(with: "task2",
                            to: #SemanticVersion("4.0.0"),
                            dependencies: ["task3"],
                            task: { /* do any async throwing work something */ })
        
await migrator.registerTask(with: "task3",
                            from: #SemanticVersion("1.0.0"),
                            maxAttempts: 3,
                            task: { /* do any async throwing work something */ })

// Finally call the start method
let results = try await migrator.start()
```

The `start` method initiates the validation of registered tasks, ensuring there are no inconsistencies. If any discrepancies are found, the following errors may be thrown:

* **invalidAppVersion:** The current app version cannot be retrieved.
* **invalidBounds:** Specified version range bounds are invalid (e.g., start version is greater than end version).
* **invalidDependency:** A task depends on another task that hasn't been declared.
* **invalidAttempts:** The specified maximum number of retry attempts is invalid (e.g., ≤ 0).
* **outdatedBounds:** The specified version bounds do not include the current app version.
* **duplicateTask:** A task is registered more than once.
* **dependencyCycle:** There's a circular dependency between tasks.
* **alreadyStarted:** An attempt was made to call the start method more than once.

Upon successful validation, the method proceeds to execute all tasks. Independant tasks are executed in parallel, enhancing efficiency. Upon completion, it provides detailed statuses for each task, including execution outcomes and reasons for any failures.




