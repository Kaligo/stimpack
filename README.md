# Stimpack 💉

Supporting libraries for NydusNetwork. Stimpack consists of a number of well
tested building blocks which can be used independently, or be combined at the
application level to build systems with consistent, well-defined interfaces
and behaviour.

## Table of Contents

- [FunctionalObject](#functionalobject)
- [OptionsDeclaration](#optionsdeclaration)
- [ResultMonad](#resultmonad)

## FunctionalObject

A simple mixin that provides a shorthand notation for instantiating and
invoking `#call` on an object.

**Example:**

Given this class definition:

```ruby
class Foo
  include FunctionalObject

  def initialize(bar:)
    @bar = bar
  end

  def call
    puts bar
  end

  private

  attr_reader :bar
end
```

we can now initialize and invoke an instance of `Foo` by calling:

```ruby
Foo.(bar: "Hello world!")
#=> "Hello world!"
```

## OptionsDeclaration

A mixin that introduces the concept of an `option`, and lets classes declare
a list options with various configuration options. Declaring an option will:

1. Add a keyword argument to the class initializer.
2. Assign an instance variable on instantiation.
3. Create an attribute reader (private by default.)

This lets us collect and condense what would otherwise be scattered throughout
the class definition.

**Example:**

Given the following options declaration:

```ruby
class Foo
  include Stimpack::OptionsDeclaration

  option :bar
  option :baz, default: []
end
```

we can now instantiate `Foo` as long as we provide the required options:

```ruby
Foo.new(bar: "Hello!")
```

### Configuration options

When declaring an option, the following configuration kets are available:

| Configuration    | Type         | Default | Notes |
| ---------------  | ------------ | ------- | ----- |
| `default`        | `any`        | `nil`   | Can be a literal or a callable object. Arrays and hashes will not be shared across instances. |
| `required`       | `boolean`    | `true`  | |
| `private_reader` | `boolean`    | `true`  | |

## ResultMonad

A mixin that is used to return structured result objects from a method. The
result will be either `successful` or `failed`, and the caller can take
whatever action they consider appropriate based on the outcome.

From within the class, the instance methods `#success` and `#error`,
respectively, can be used to construct the result object.

**Example:**

```ruby
class Foo
  include Stimpack::ResultMonad

  blank_result

  def call
    return error(errors: "Whoops!") if operation_failed?

    success
  end
end
```

Successful results can optionally be parameterized with additional data using
the `#result` method. The declared result key will be required to be passed to
the `#success` constructor method.

**Example:**

```ruby
class Foo
  include Stimpack::ResultMonad

  result :bar

  def call
    success(bar: "It worked!")
  end
end
```

Consumers of the class can then decide what to do based on the outcome:

```ruby
result = Foo.new.()

if result.successful?
  result.bar
else
  result.errors
end
```
