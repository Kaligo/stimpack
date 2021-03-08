# Stimpack 💉

Supporting libraries for NydusNetwork. Stimpack consists of a number of well
tested building blocks which can be used independently, or be combined at the
application level to build systems with consistent, well-defined interfaces
and behaviour.

## Table of Contents

- [FunctionalObject](#functionalobject)

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
