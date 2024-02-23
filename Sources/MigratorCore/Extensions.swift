//
//  Extensions.swift
//
//
//  Created by Narek Sahakyan on 23.02.24.
//

import Foundation

extension Result: Codable where Success: Codable, Failure: Codable {
    enum CodingKeys: CodingKey {
        case success
        case failure
    }

    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .success(let successValue):
            try container.encode(successValue, forKey: .success)
        case .failure(let failureValue):
            try container.encode(failureValue, forKey: .failure)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let successValue = try container.decodeIfPresent(Success.self, forKey: .success) {
            self = .success(successValue)
        } else if let failureValue = try container.decodeIfPresent(Failure.self, forKey: .failure) {
            self = .failure(failureValue)
        } else {
            throw DecodingError.dataCorruptedError(forKey: .success, in: container, debugDescription: "Result values not found.")
        }
    }
}

extension UserDefaults: @unchecked Sendable {
    static let encoder = JSONEncoder()
    static let decoder = JSONDecoder()

    func save<T: Codable>(_ object: T, forKey key: String) {
        do {
            let data = try Self.encoder.encode(object)
            set(data, forKey: key)
        } catch {
            print("Unable to Encode Object (\(error))")
        }
    }

    func fetch<T: Codable>(forKey key: String, type: T.Type) -> T? {
        guard let data = data(forKey: key) else { return nil }

        do {
            let object = try Self.decoder.decode(T.self, from: data)
            return object
        } catch {
            print("Unable to Decode Object (\(error))")
            return nil
        }
    }
}
