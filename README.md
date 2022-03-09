# Stimpack 💉

Supporting libraries for NydusNetwork. Stimpack consists of a number of well
tested building blocks which can be used independently, or be combined at the
application level to build systems with consistent, well-defined interfaces
and behaviour.

## Table of Contents

- [EventSource](#eventsource)
  - [Error handling](#error-handling)
- [FunctionalObject](#functionalobject)
- [OptionsDeclaration](#optionsdeclaration)
- [ResultMonad](#resultmonad)
  - [Callbacks](#callbacks)
  - [Guard clauses](#guard-clauses)

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
Foo.on(:bar, :qui, :qux) do |event|
  puts event.message
end

Foo.new.bar
#=> "Hello, world!"
Foo.new.qui
#=> "Hello, world!"
Foo.new.qux
#=> "Hello, world!"
```

*Note: Callbacks are invoked synchronously in the same thread, so don't use
this to perform long-running tasks. You can use the event listener to schedule
a background job, though!*

### Error handling

By default, all errors that occur in a callback are rescued unhandled. This is
intentional and by design, since most of the time, we don't want outside code
invoked by event listener to be able to interrupt the main flow.

If you decide that you want to handle these errors yourself, you can configure
the listener to re-raise any errors when you register it.

**Example:**

```ruby
Foo.on(:bar, raise_errors: true) do |event|
  puts event.message
rescue StandardError => error
  log_error(error.message)
end
```

Alternatively, you can configure an event handler for all `EventSource` classes
to use. The error handler needs to respond fo `#call` and will be passed a
single argument, the error that was raised:

**Example:**

```ruby
EventSource.error_handler = ->(error) { AppSignal.error(error) }
```

This can be useful for instrumentation, and to handle errors differently
depending on which environment the code is running in.

*Note: Once configured, this will apply to all listeners.*

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

You can optionally pass a block to the call which will receive the result of
the method and will execute before returning.

**Note: The result is still always returned.**

```ruby
Foo.(bar: "Hello world!") do |result|
  if result.successful?
    # Do stuff.
  else
    # Report errors.
  end
end
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

| Configuration    | Type            | Default | Notes |
| ---------------  | --------------- | ------- | ----- |
| `default`        | `any`           | `nil`   | Can be a literal or a callable object. Arrays and hashes will not be shared across instances. |
| `required`       | `boolean`       | `true`  | |
| `transform`      | `symbol`/`proc` | `noop`  | Can be a symbol that is a method on the value, or a callable object that takes the value as argument. |
| `private_reader` | `boolean`       | `true`  | |

### Transformations

You can declare transformations which will be performed on the value when
assigned. This also works with default values. (The transformation will be
applied to the default value.)

**Example:**

Given the following declaration:

```ruby
class Foo
  include Stimpack::OptionsDeclaration

  option :bar, transform: ->(value) { value.upcase }
end
```

values assigned to `bar` will now be upcased:

```ruby
foo = Foo.new(bar: "baz")

foo.bar
#=> "BAZ"
```

You can also use the name of method on the value, passed as a symbol.

**Example:**

Given the following declaration:

```ruby
class Foo
  include Stimpack::OptionsDeclaration

  option :bar, transform: :symbolize_keys
end
```

hashes assigned to `bar` will now have their keys symbolized:

```ruby
foo = Foo.new(bar: { "baz" => "qux" })

foo.bar
#=> { baz: "qux" }
```

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

The `ResultMonad` mixin exposes four callbacks, `before_success`, `after_success`,
`before_error` and `after_error`. These can be configured by passing a block to 
them in the class body.

*Note: Declaring an already declared callback in the same class will overwrite
the previous one.*

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

Callbacks are inherited, and all inherited callbacks will be invoked as they
are traversed up the inheritance chain. In this case, all callbacks are
evaluated in the context of the class where the `success` or `error` method
was called.

**Example:**

```ruby
class Foo
  include Stimpack::ResultMonad

  before_success do
    puts "Parent"
  end
end

class Bar < Foo
  before_success do
    puts "Child"
  end

  def call
    success
  end
end

Bar.()
#=> "Child"
#=> "Parent"
```

### Guard clauses

The `ResultMonad::GuardClause` mixin (included by default) allows for stepwise
calling of inner, or nested, `ResultMonad` instances with automatic error
propagation. This currently works for the `#call` method only.

**Example:**

```ruby
class Foo
  include Stimpack::ResultMonad

  before_error do
    log_tracking_data
  end

  def call
    guard :bar_guard
    qux = guard { baz_guard }
  end

  private

  def log_tracking_data
    # ...
  end

  def bar_guard
    Bar.() # Another ResultMonad.
  end

  def baz_guard
    if qux?
      pass("Qux")
    else
      error(errors: ["Qux failed."])
    end
  end
end
```

In the example above, if either of the methods declared as guards return a
failed `Result`, the `#call` method will halt execution, invoke the error
callback, and return the result from the inner monad. On the other hand, as
long as the guards return a success `Result`, the execution continues as
expected.

*Note: Any error callbacks declared on the inner monad will also be invoked.*

Guard clauses use `raise` and `rescue` internally, but the exception used is
directly inherited from `Exception`, so it is safe to rescue anything downstream
of that, e.g. `StandardError` in your methods which have guard clauses.
