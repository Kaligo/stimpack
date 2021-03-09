# Stimpack 💉

Supporting libraries for NydusNetwork. Stimpack consists of a number of well
tested building blocks which can be used independently, or be combined at the
application level to build systems with consistent, well-defined interfaces
and behaviour.

## Table of Contents

- [EventSource](#eventsource)
- [FunctionalObject](#functionalobject)
- [OptionsDeclaration](#optionsdeclaration)
- [ResultMonad](#resultmonad)

## EventSource

A mixin that turns the class into an event emitter with which others can
register listeners. The class can then use `#emit` to broadcast events to any
listensers.

**Example:**

Given the following event source:

```ruby
class Foo
  include Stimpack::EventSource

  def bar
    emit(:bar, { message: "Hello, world!" })
  end
end
```

we can register a callback to listen for events from another part of our
application, and we will receive an event object when the event is emitted:

```ruby
Foo.on(:bar) do |event|
  puts event.message
end

Foo.new.bar
#=> "Hello, world!"
```

*Note: Callbacks are invoked synchronously in the same thread, so don't use
this to perform long-running tasks. You can use the event listener to schedule
a background job, though!*

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

### Callbacks

The `ResultMonad` mixin exposes two callbacks, `before_success` and
`before_error`. These can be configured by passing a block to them in the
class body.

*Note: Callbacks are not inherited, and declaring multiple callbacks in the
same class will overwrite the previous one.*

**Example:**

```ruby
class Foo
  include Stimpack::ResultMonad

  before_success do
    log_tracking_data
  end

  private

  def log_tracking_data
    # ...
  end
end
```

*Note: The block is evaluated in the context of the instance, so you can call
any instance methods from inside the block.*
