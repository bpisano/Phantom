# PhantomType

A Swift package to easily create phantom types for enhanced type safety.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
  - [Accessing values](#accessing-values)
  - [Custom typealias name](#custom-typealias-name)
- [License](#license)

## Installation

Add the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/bpisano/phantom", .upToNextMajor(from: "1.0.0"))
]
```

## Usage

Add the `@Phantom` macro to your struct and mark the property you want to use as the identifier with `@PhantomProperty`.

```swift
import PhantomType

@Phantom
struct Person {
    @PhantomProperty
    var id: UUID
}
```

The `@Phantom` macro will expand to the following:

```swift
struct Person {
    typealias Id = PhantomType<UUID, Person>

    @PhantomWrapped<UUID, Person>
    var id: UUID
}
```

This allows you to initialize the struct as usual, while also generating a phantom type for the specified property for enhanced type safety.

```swift
// Improved type safety
func registerPerson(withId id: Person.Id) { }

// Initialize a Person with a regular UUID, not the phantom type
let person: Person = .init(id: UUID())
registerPerson(withId: person.$id)
```

### Accessing values

You can access both the phantom type and the raw value using the generated properties.

```swift
let person: Person = .init(id: UUID())

print("Person ID: \(person.$id)") // Access the phantom type
print("Raw ID: \(person.id)") // Access the raw value
```

### Custom typealias name

By default, the typealias name is derived from the property name. You can optionally specify a custom name for the generated typealias:

```swift
import PhantomType

@Phantom
struct Person {
    @PhantomProperty("PersonID")
    var id: UUID
}
// Generates: typealias PersonID = PhantomType<UUID, Person>

let person: Person = .init(id: UUID())
func register(personId: Person.PersonID) {
    // Implementation
}
register(personId: person.$id)
```

## License

PhantomType is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
