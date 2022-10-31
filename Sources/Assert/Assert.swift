import XCTest

public protocol OptionalType {
    associatedtype Wrapped
    var unwrapped: Wrapped? { get }
}

extension Optional: OptionalType {
    public var unwrapped: Wrapped? {
        switch self {
        case .some(let value): return value
        case .none: return nil
        }
    }
}

public func assert<T>(_ value: @autoclosure () throws -> T) rethrows -> Assert<T> {
    try .init(value())
}

public func assertThrows<T>(_ closure: @autoclosure () throws -> T, file: StaticString = #file, line: UInt = #line) {
    XCTAssertThrowsError(try closure(), file: file, line: line)
}

public func scope<T>(_ scope: T, _ closure: (Assert<T>) throws -> Void) rethrows {
    try closure(assert(scope))
}

public func unwrap<T: OptionalType>(_ value: T) throws -> Assert<T.Wrapped> {
    try assert(value).unwrap()
}

@dynamicMemberLookup
public struct Assert<T> {
    public let value: T

    public init(_ value: T) {
        self.value = value
    }

    public subscript<Value>(dynamicMember keyPath: KeyPath<T, Value>) -> Assert<Value> {
        assert(value[keyPath: keyPath])
    }

    public func scope(_ closure: @escaping (Self) throws -> Void) rethrows {
        try closure(self)
    }

    public func map<U>(_ closure: (T) -> U) -> Assert<U> {
        .init(closure(value))
    }

    public func explodes<T>(_ closure: @escaping (Self) throws -> T, file: StaticString = #file, line: UInt = #line) rethrows {
        XCTAssertThrowsError(try closure(self), file: file, line: line)
    }
}

extension Assert where T: Sequence, T.Element: Comparable {
    public func sorted() -> Assert<[T.Element]> {
        .init(value.sorted())
    }
}

extension Assert where T: OptionalType {
    public func isNil(file: StaticString = #file, line: UInt = #line) {
        XCTAssertNil(value.unwrapped, file: file, line: line)
    }

    public func notNil(file: StaticString = #file, line: UInt = #line) {
        XCTAssertNotNil(value.unwrapped, file: file, line: line)
    }

    public func unwrap(file: StaticString = #file, line: UInt = #line) throws -> Assert<T.Wrapped> {
        .init(try XCTUnwrap(value.unwrapped, file: file, line: line))
    }
}

extension Assert where T: AnyObject {
    public func identical(to other: T, file: StaticString = #file, line: UInt = #line) {
        XCTAssertIdentical(value, other, file: file, line: line)
    }

    public func notIdentical(to other: T, file: StaticString = #file, line: UInt = #line) {
        XCTAssertNotIdentical(value, other, file: file, line: line)
    }
}

extension Assert where T == Bool {
    public func isTrue(file: StaticString = #file, line: UInt = #line) {
        XCTAssertTrue(value, file: file, line: line)
    }

    public func isFalse(file: StaticString = #file, line: UInt = #line) {
        XCTAssertFalse(value, file: file, line: line)
    }
}

extension Assert where T: Equatable {
    public func equal(to other: T, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(value, other, file: file, line: line)
    }

    public func notEqual(to other: T, file: StaticString = #file, line: UInt = #line) {
        XCTAssertNotEqual(value, other, file: file, line: line)
    }
}

extension Assert where T: Comparable {
    public func greater(than other: T, file: StaticString = #file, line: UInt = #line) {
        XCTAssertGreaterThan(value, other, file: file, line: line)
    }

    public func greaterThanOrEqual(to other: T, file: StaticString = #file, line: UInt = #line) {
        XCTAssertGreaterThanOrEqual(value, other, file: file, line: line)
    }

    public func less(than other: T, file: StaticString = #file, line: UInt = #line) {
        XCTAssertLessThan(value, other, file: file, line: line)
    }

    public func lessThanOrEqual(to other: T, file: StaticString = #file, line: UInt = #line) {
        XCTAssertLessThanOrEqual(value, other, file: file, line: line)
    }

    public func within(_ range: ClosedRange<T>, file: StaticString = #file, line: UInt = #line) {
        XCTAssertTrue(range ~= value, file: file, line: line)
    }

    public func outsideOf(_ range: ClosedRange<T>, file: StaticString = #file, line: UInt = #line) {
        XCTAssertFalse(range ~= value, file: file, line: line)
    }
}

public func === <T: AnyObject>(lhs: Assert<T>, rhs: T) {
    lhs.identical(to: rhs)
}

public func !== <T: AnyObject>(lhs: Assert<T>, rhs: T) {
    lhs.notIdentical(to: rhs)
}

public func == <T: Equatable>(lhs: Assert<T>, rhs: T) {
    lhs.equal(to: rhs)
}

public func != <T: Equatable>(lhs: Assert<T>, rhs: T) {
    lhs.notEqual(to: rhs)
}

public func < <T: Comparable>(lhs: Assert<T>, rhs: T) {
    lhs.less(than: rhs)
}

public func <= <T: Comparable>(lhs: Assert<T>, rhs: T) {
    lhs.lessThanOrEqual(to: rhs)
}

public func > <T: Comparable>(lhs: Assert<T>, rhs: T) {
    lhs.greater(than: rhs)
}

public func >= <T: Comparable>(lhs: Assert<T>, rhs: T) {
    lhs.greaterThanOrEqual(to: rhs)
}

public func ~= <T: Comparable>(lhs: ClosedRange<T>, rhs: Assert<T>) {
    rhs.within(lhs)
}

infix operator !~=: ComparisonPrecedence
public func !~= <T: Comparable>(lhs: ClosedRange<T>, rhs: Assert<T>) {
    rhs.outsideOf(lhs)
}

infix operator =~: ComparisonPrecedence
public func =~ <T: Comparable>(lhs: Assert<T>, rhs: ClosedRange<T>) {
    lhs.within(rhs)
}

infix operator !=~: ComparisonPrecedence
public func !=~ <T: Comparable>(lhs: Assert<T>, rhs: ClosedRange<T>) {
    lhs.outsideOf(rhs)
}
