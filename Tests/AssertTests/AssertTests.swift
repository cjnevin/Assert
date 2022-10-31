import XCTest
@testable import Assert

final class AssertTests: XCTestCase {
    let obj = User.Test()
    lazy var user = User(
        object: obj,
        name: "test",
        id: 1,
        optional: nil,
        prefs: .init(email: true, phone: true),
        array: ["a", "b"],
        dictionary: ["a": 1, "b": 2]
    )

    func testReferenceType() {
        assert(user.object) === obj
        assert(user.object) !== .init()
    }

    func testDynamicMemberLookup() {
        assert(user.prefs.email) == true
        assert(user.array.isEmpty) == false
    }

    func testComparable() {
        assert(user.id) {
            $0 > 0
            $0 >= 0
            $0 < 2
            $0 <= 2
            $0 =~ 0...2
            0...2 ~= $0
            $0 !=~ 2...4
            2...4 !~= $0
        }
    }

    func testAssertThrows() {
        struct TestError: Error {}
        func test() throws {
            throw TestError()
        }
        assertThrows(try test())
    }

    func testMap() {
        assert(user.name).map { String($0.reversed()) } == "tset"
    }

    func testSorted() {
        assert(user.dictionary.keys.sorted()) == ["a", "b"]
        assert(user.dictionary.values.sorted()) == [1, 2]
    }

    func testOptional() throws {
        var copy = user
        assert(copy.optional) == nil
        assert(copy.optional).isNil()

        copy.optional = "abc"
        assert(copy.optional) == "abc"
        assert(copy.optional).notNil()

        try assert(copy.optional).unwrap() == "abc"
    }

    func testScopedAssert() {
        assert(user.prefs) {
            $0.email == true
            $0.phone == true
        }
        assert(user) {
            $0.prefs.assert {
                $0.email == true
                $0.phone == true
            }
        }
    }
}

struct User {
    struct Prefs: Equatable {
        var email: Bool
        var phone: Bool
    }
    class Test {}
    var object: Test
    var name: String
    var id: Int
    var optional: String?
    var prefs: Prefs
    var array: [String]
    var dictionary: [String: Int]
}
