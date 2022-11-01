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
  $0.prefs.scope {
    $0.email == true
    $0.phone == false
  }
}

// sorted
assert(user.dictionary.keys.sorted()) == ["a", "b"]

// unwrap optional
try assert(user.optional).unwrap() == "abc"
try unwrap(user.optional) == "abc"
try assert(try unwrap(user.optional)) {
  $0.isEmpty == false
}
```
