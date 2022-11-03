# Assert

Thin wrapper over XCTest functions to make them more readable.

```swift
assert(user.name) == "test"
assert(user.array) == [1, 2]

// less than or equal
assert(user.id) <= 1 

// less than
assert(user.id) < 2 

// greater than or equal
assert(user.id) >= 1 

// greater than
assert(user.id) > 0 

// within range
assert(user.id) {
  // within range
  $0 =~ 0...2
  0...2 ~= $0
  
  // not within range
  $0 !=~ 2...4
  2...4 !~= $0
}

// scoping
assert(user.prefs) {
  $0.email == true
  $0.phone == false
}
assert(user) {
  assert($0.prefs) {
    $0.email == true
    $0.phone == false
  }
}

// sorted
assert(user.dictionary.keys.sorted()) == ["a", "b"]

// unwrap optional
try assert(user.optional).unwrap() == "abc"
try assert(unwrapping: user.optional) == "abc"
try assert(unwrapping: user.optional) {
  $0.isEmpty == false
}

// async
await assert(await getUserName()) == "test"
try await assert(unwrapping: try await getOptional()) == "abc"

// using words
assert(user.prefs.email).isTrue()
assert(user.prefs.sms).isFalse()
assert(user.prefs.name).equals("test")
```
