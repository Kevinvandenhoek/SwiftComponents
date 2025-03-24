//
//  Loadable.swift
//
//
//  Created by Kevin van den Hoek on 27/10/2023.
//

import Foundation

public protocol LoadableProtocol {
    
    associatedtype Value
    
    var value: Value? { get set }
    var placeholder: Value { get set }
    var error: Error? { get }
    var isLoading: Bool { get }
    var state: LoadingState<Value> { get }
    var valueOrPlaceholder: Value { get }
}

public struct Loadable<Value: Sendable>: LoadableProtocol, Sendable {
    
    public var state: LoadingState<Value> {
        didSet {
            switch state {
            case .loaded(let value):
                placeholder = value
            default:
                break
            }
        }
    }
    public var placeholder: Value {
        didSet {
            guard let value = value as? Encodable, let key = storage.key else { return }
            UserDefaults.standard.set(key: key, to: value)
        }
    }
    public var valueOrPlaceholder: Value { value ?? placeholder }
    
    private let storage: PlaceholderStorage
    
    public var value: Value? {
        get {
            switch state {
            case .loaded(let value):
                return value
            default:
                return nil
            }
        }
        set {
            if let newValue {
                state = .loaded(newValue)
            } else {
                state = .initial
            }
        }
    }
    public var error: Error? {
        switch state {
        case .error(let error):
            return error
        default:
            return nil
        }
    }
    public var isLoading: Bool {
        switch state {
        case .loading, .initial:
            return true
        default:
            return false
        }
    }
    public var isInitial: Bool {
        switch state {
        case .initial:
            return true
        default:
            return false
        }
    }
    
    // MARK: Lifecycle
    public static func placeholder(_ placeholder: Value, storage: PlaceholderStorage = .default) -> Self {
        return .init(.initial, placeholder: placeholder, storage: storage)
    }
    
    public static func loaded(_ value: Value, storage: PlaceholderStorage = .default) -> Self {
        return .init(.loaded(value), placeholder: value, storage: storage)
    }
    
    public init(_ state: LoadingState<Value> = .initial, placeholder: Value, storage: PlaceholderStorage = .default) {
        self.state = state
        self.storage = storage
        if let key = storage.key, let existing: Value = UserDefaults.standard.get(key: key) {
            self.placeholder = existing
        } else {
            self.placeholder = placeholder
        }
    }
}

public enum LoadingState<Value: Sendable>: Sendable {
    
    case initial
    case loading
    case error(Error)
    case loaded(Value)
}

extension LoadingState: Equatable {
    
    public static func == (lhs: LoadingState<Value>, rhs: LoadingState<Value>) -> Bool {
        switch lhs {
        case .initial:
            if case .initial = rhs {
                return true
            } else {
                return false
            }
        case .loading:
            if case .loading = rhs {
                return true
            } else {
                return false
            }
        case .error(let lhsError):
            if case .error(let rhsError) = rhs {
                let lhsErrorEquatable = lhsError as any Equatable
                let rhsErrorEquatable = rhsError as any Equatable
                return AnyEquatable(lhsErrorEquatable) == AnyEquatable(rhsErrorEquatable)
            } else {
                return false
            }
        case .loaded(let lhsValue):
            if case .loaded(let rhsValue) = rhs {
                if let lhsValueEquatable = lhsValue as? any Equatable,
                   let rhsValueEquatable = rhsValue as? any Equatable {
                    return AnyEquatable(lhsValueEquatable) == AnyEquatable(rhsValueEquatable)
                } else {
                    return String(describing: lhsValue) == String(describing: rhsValue)
                }
            } else {
                return false
            }
        }
    }
    
    private struct AnyEquatable: Equatable {
        private let value: any Equatable
        private let equals: (any Equatable) -> Bool
        
        init<T: Equatable>(_ value: T) {
            self.value = value
            self.equals = { ($0 as? T) == value }
        }

        static func == (lhs: AnyEquatable, rhs: AnyEquatable) -> Bool {
            return lhs.equals(rhs.value)
        }
    }
}

extension Loadable {
    
    public enum PlaceholderStorage: Sendable {
        /// Whenever a value is loaded, a persistent placeholder of the same value will be written to storage if possible
        case `default`
        /// Whenever a value is loaded, a persistent placeholder of the same value will be written to storage if possible, but with a custom key
        case key(String)
        /// No persistent placeholder storage
        case none
        
        var key: String? {
            switch self {
            case .default:
                return "SwiftComponents.Loadable.\(String(describing: type(of: Value.self)))"
            case .key(let string):
                return string
            case .none:
                return nil
            }
        }
    }
}

public extension Loadable {
    
    func map<NewValue>(_ transform: (Value) -> NewValue) -> Loadable<NewValue> {
        switch state {
        case .initial:
            return .init(.initial, placeholder: transform(placeholder))
        case .loading:
            return .init(.loading, placeholder: transform(placeholder))
        case .error(let error):
            return .init(.error(error), placeholder: transform(placeholder))
        case .loaded(let value):
            return .init(.loaded(transform(value)), placeholder: transform(placeholder))
        }
    }
}

public extension Array where Element == any LoadableProtocol {
    
    var didAllLoad: Bool {
        return !contains(where: { $0.isLoading })
    }
    
    var firstError: Error? {
        return compactMap({ $0.error })
            .first
    }
}
