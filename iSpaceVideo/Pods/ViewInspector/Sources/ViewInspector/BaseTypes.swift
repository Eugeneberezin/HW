import SwiftUI

// MARK: - Protocols

public protocol Inspectable {
    var content: Any { get }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension Inspectable where Self: View {
    var content: Any { body }
}

public protocol SingleViewContent {
    static func child(_ content: Content) throws -> Content
}

public protocol MultipleViewContent {
    static func children(_ content: Content) throws -> LazyGroup<Content>
}

public protocol KnownViewType {
    static var typePrefix: String { get }
}

public protocol CustomViewType {
    associatedtype T: Inspectable
}

@available(iOS 11.0, macOS 10.15, tvOS 13.0, *)
public struct ViewType { }

@available(iOS 11.0, macOS 10.15, tvOS 13.0, *)
public struct Content {
    let view: Any
    let modifiers: [Any]
    
    internal init(_ view: Any, modifiers: [Any] = []) {
        self.view = view
        self.modifiers = modifiers
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension Binding {
    init(wrappedValue: Value) {
        var value = wrappedValue
        self.init(get: { value }, set: { value = $0 })
    }
}

// MARK: - Error

public enum InspectionError: Swift.Error {
    case typeMismatch(factual: String, expected: String)
    case attributeNotFound(label: String, type: String)
    case viewIndexOutOfBounds(index: Int, count: Int)
    case viewNotFound(parent: String)
    case modifierNotFound(parent: String, modifier: String)
    case notSupported(String)
    case textAttribute(String)
}

extension InspectionError: CustomStringConvertible, LocalizedError {
    
    public var description: String {
        switch self {
        case let .typeMismatch(factual, expected):
            return "Type mismatch: \(factual) is not \(expected)"
        case let .attributeNotFound(label, type):
            return "\(type) does not have '\(label)' attribute"
        case let .viewIndexOutOfBounds(index, count):
            return "Enclosed view index '\(index)' is out of bounds: '0 ..< \(count)'"
        case let .viewNotFound(parent):
            return "View for \(parent) is absent"
        case let .modifierNotFound(parent, modifier):
            return "\(parent) does not have '\(modifier)' modifier"
        case let .notSupported(message), let .textAttribute(message):
            return message
        }
    }
    
    public var errorDescription: String? {
        return description
    }
}

// MARK: - LazyGroup

public struct LazyGroup<T> {
    
    private let access: (Int) throws -> T
    let count: Int
    
    init(count: Int, _ access: @escaping (Int) throws -> T) {
        self.count = count
        self.access = access
    }
    
    func element(at index: Int) throws -> T {
        guard 0 ..< count ~= index else {
            throw InspectionError.viewIndexOutOfBounds(index: index, count: count)
        }
        return try access(index)
    }
    
    static var empty: Self {
        return .init(count: 0) { _ in fatalError() }
    }
}

extension LazyGroup: Sequence {
    
    public struct Iterator: IteratorProtocol {
        public typealias Element = T
        private var index = -1
        private var group: LazyGroup<Element>
        
        init(group: LazyGroup<Element>) {
            self.group = group
        }
        
        mutating public func next() -> Element? {
            index += 1
            do {
                return try group.element(at: index)
            } catch _ {
                return nil
            }
        }
    }

    public func makeIterator() -> Iterator {
        .init(group: self)
    }

    public var underestimatedCount: Int { count }
}

// MARK: - BinaryEquatable

internal protocol BinaryEquatable: Equatable { }

extension BinaryEquatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        withUnsafeBytes(of: lhs) { lhsBytes -> Bool in
            withUnsafeBytes(of: rhs) { rhsBytes -> Bool in
                lhsBytes.elementsEqual(rhsBytes)
            }
        }
    }
}
