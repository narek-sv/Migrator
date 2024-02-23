//
//  Migrator.swift
//
//
//  Created by Narek Sahakyan on 23.02.24.
//

import Foundation

public actor Migrator {
    public typealias TaskID = String
    private static let taskStatusKey = "Migrator.Task.Statuses"
    
    private let storage: UserDefaults
    private let bundle: Bundle
    private var dependencyGraph = DirectedAcyclicGraph<TaskID>()
    private var taskItems = [TaskID: TaskItem]()
    private var taskStatuses = [TaskID: Status]()
    private var registrationTasks = [(() throws -> ())]()
    private var alreadyStarted = false
    private lazy var appVersion = bundle.semanticVersion

    public init(storage: UserDefaults = .standard, bundle: Bundle = .main) {
        self.storage = storage
        self.bundle = bundle
    }
    
    public func registerTask(with id: TaskID,
                             from start: SemanticVersion = .oldest,
                             to end: SemanticVersion = .newest,
                             dependencies: Set<TaskID> = [],
                             maxAttempts: Int = 1,
                             task: @escaping () async throws -> ()) {
        registrationTasks.append { [unowned self] in
            guard let appVersion else { throw SetupError.invalidAppVersion }
            guard start <= end else { throw SetupError.invalidBounds }
            guard start <= appVersion && appVersion <= end else { throw SetupError.outdatedBounds }
            guard maxAttempts > 0 else { throw SetupError.invalidAttempts }
            guard taskItems[id] == nil else { throw SetupError.duplicateTask }
            
            dependencyGraph.addVertex(node: id, adjacents: dependencies)
            taskItems[id] = .init(id: id,
                                  start: start,
                                  end: end,
                                  maxAttempts: maxAttempts,
                                  task: task)
        }
    }
    
    // The method throws SetupError only if the setup was incorrecet
    // It returns a dictionary containing information about execution of each task
    public func start() async throws -> [TaskID: Status] {
        guard !alreadyStarted else { throw SetupError.alreadyStarted }
        alreadyStarted = true
        
        try registrationTasks.forEach { try $0() }
        registrationTasks.removeAll()
        
        guard let taskIDs = dependencyGraph.topologicalSort() else { throw SetupError.dependencyCycle }
        guard !taskIDs.contains(where: { taskItems[$0] == nil }) else { throw SetupError.invalidDependency }

        taskStatuses = storage.fetch(forKey: Self.taskStatusKey, type: [TaskID: Status].self) ?? [:]
        
        await executeTasks(taskIDs: taskIDs)
        return taskStatuses
    }
    
    private func executeTasks(taskIDs: [TaskID]) async {
        let remainingTasks = taskIDs
            .filter { !isCompleted($0) && !isFailed($0) }
            .filter {
                if isExceeded($0) {
                    markTaskFailed(taskID: $0, error: .exceededAttempts)
                    return false
                }
                            
                return true
            }
            .filter {
                if dependencyGraph.adjacencyList[$0]!.contains(where: { isFailed($0) }) {
                    markTaskFailed(taskID: $0, error: .dependencyFailed)
                    return false
                }
                
                return true
            }
        
        if remainingTasks.isEmpty {
            return
        }
        
        
        let validExecutableTasks = remainingTasks
            .filter { !isInProgress($0) && dependencyGraph.adjacencyList[$0]!.allSatisfy({ isCompleted($0) }) }
        
        await withTaskGroup(of: Void.self, body: { taskGroup in
            for taskID in validExecutableTasks {
                taskGroup.addTask { [unowned self] in
                    await executeTask(taskID: taskID)
                    await executeTasks(taskIDs: remainingTasks)
                }
            }
        })
    }
    
    private func executeTask(taskID: TaskID) async {
        markTaskInProgress(taskID: taskID)
        
        if let task = taskItems[taskID]?.task {
            do {
                try await task()
                markTaskCompleted(taskID: taskID)
            } catch {
                markTaskFailed(taskID: taskID, taskError: error)
            }
        }
    }
    
    // MARK: - Status Checks

    private func isCompleted(_ taskID: TaskID) -> Bool {
        let status = self.status(for: taskID)
        
        if case .success = status.completionStatus, !status.isInProgress {
            return true
        }
        
        return false
    }

    private func isFailed(_ taskID: TaskID) -> Bool {
        let status = self.status(for: taskID)

        if case .failure = status.completionStatus, !status.isInProgress {
            return true
        }
        
        return false
    }
    
    private func isInProgress(_ taskID: TaskID) -> Bool {
        let status = self.status(for: taskID)
        return status.isInProgress
    }

    private func isExceeded(_ taskID: TaskID) -> Bool {
        let status = self.status(for: taskID)
        return status.failedAttempts >= (taskItems[taskID]?.maxAttempts ?? 0)
    }
    
    // MARK: - Status Updates

    private func markTaskCompleted(taskID: TaskID) {
        let status = self.status(for: taskID)
        let success = Success(completionDate: Date())
        let newStatus = Status(taskID: taskID,
                               failedAttempts: status.failedAttempts,
                               completionStatus: .success(success))
        
        updateTaskStatus(newStatus)
    }
    
    private func markTaskInProgress(taskID: TaskID) {
        let status = self.status(for: taskID)
        let newStatus = Status(taskID: taskID,
                               failedAttempts: status.failedAttempts,
                               completionStatus: status.completionStatus,
                               isInProgress: true)
        
        updateTaskStatus(newStatus)
    }
    
    private func markTaskFailed(taskID: TaskID, taskError: Error) {
        let status = self.status(for: taskID)
        let failure = Failure(lastFailDate: Date(), reason: .taskFailed(errorMessage: taskError.localizedDescription))
        let newStatus = Status(taskID: taskID,
                               failedAttempts: status.failedAttempts + 1,
                               completionStatus: .failure(failure))
        
        updateTaskStatus(newStatus)
    }
    
    private func markTaskFailed(taskID: TaskID, error: ExecutionError) {
        let status = self.status(for: taskID)
        let failure = Failure(lastFailDate: Date(), reason: error)
        let newStatus = Status(taskID: taskID,
                               failedAttempts: status.failedAttempts,
                               completionStatus: .failure(failure))
        
        updateTaskStatus(newStatus)
    }
    
    // MARK: - Status Persistence
    
    private func persistedTaskStatuses() -> [TaskID: Status] {
        storage.fetch(forKey: Self.taskStatusKey, type: [TaskID: Status].self) ?? [:]
    }
    
    private func updateTaskStatus(_ newStatus: Status) {
        taskStatuses[newStatus.taskID] = newStatus
        
        Task {
            var persistedStatuses = persistedTaskStatuses()
            persistedStatuses[newStatus.taskID] = newStatus
            storage.save(persistedStatuses, forKey: Self.taskStatusKey)
        }
    }
    
    private func status(for id: TaskID) -> Status {
        taskStatuses[id] ?? .init(taskID: id,
                                  failedAttempts: 0,
                                  completionStatus: .success(.init(completionDate: .init())),
                                  isInProgress: true)
    }
}

public extension Migrator {
    enum SetupError: Sendable, Error {
        // Can't retrieve current app's version
        case invalidAppVersion
        
        // The bounds are invalid (for example start > end)
        case invalidBounds
        
        // One of the tasks has a dependency which is not declared
        case invalidDependency
        
        // Max attempts parameter is invalid (for example <= 0)
        case invalidAttempts
        
        // The bounds doesn't include current app version
        case outdatedBounds
        
        // The task is registered more than once
        case duplicateTask
        
        // There is a cycle between the dependencies
        case dependencyCycle
        
        // Each upgrader should only be started once
        case alreadyStarted
    }
    
    enum ExecutionError: Codable, Sendable, Error {
        // The task failed because one of it's dependencies failed
        case dependencyFailed
        
        // The task failed because it exceeded max attempts
        case exceededAttempts
        
        // The task failed because it throwed an error
        case taskFailed(errorMessage: String)
    }
}

private extension Migrator {
    struct TaskItem {
        let id: TaskID
        let start: SemanticVersion?
        let end: SemanticVersion?
        let maxAttempts: Int
        let task: (() async throws -> ())
    }
}

public extension Migrator {
    struct Status: Sendable, Codable {
        public let taskID: TaskID
        public let failedAttempts: Int
        public let completionStatus: Result<Success, Failure>
        fileprivate var isInProgress = false
    }
    
    struct Success: Sendable, Codable {
        public let completionDate: Date
    }
    
    struct Failure: Sendable, Codable, Error {
        public let lastFailDate: Date
        public let reason: ExecutionError
    }
}
