# Changelog

## 0.9.1

### Bug fixes

- Prevent mutable default options from being shared across instances.

## 0.9.0

### New features

- `ResultMonad` callbacks (`before_success`, `before_error`) are now inherited.

## 0.8.3

### New features

- Listen on multiple event names to `EventSource` listener.

## 0.8.2

### Bug fixes

- Have `GuardFailed` inherit from `Exception` instead of `StandardError`.

## 0.8.1

## Maintenance

- Loosen the ActiveSupport dependency version to prepare for Rails 7.

## 0.8.0

### New features

- Yield the result of the call from `FunctionalObject` if block is given.

## 0.7.1

### New features

- Add `ResultMonad::GuardClause#pass` method which can be used to pass guards.

## 0.7.0

### New features

- Add guard clauses through new `ResultMonad::GuardClause` mixin.

## 0.6.1

### New features

- Allow transform declaration with optional value to `OptionsDeclaration`.

## 0.6.0

### New features

- Add support for transformation methods to `OptionsDeclaration`.

## 0.5.6

### Bug fixes

- Add back dependency on `ActiveSupport#class_attribute` which was dropped
  prematurely.

## 0.5.5

### New features

- Add `error_handler` configuration option to the `EventSource` module.

## 0.5.4

### New features

- Add nicely formatted inspect output for `ResultMonad::Result`.

### Maintenance

- Split child classes of `EventSource` and `OptionsDeclaration` into own files.
- Add a bunch more inline documentation for the mixins.
- Remove `EventSource` and `ResultMonad` dependencies on ActiveSupport.

## 0.5.3

### New features

- Allow `default: nil` to be used without needing `required: false` for the
  `OptionsDeclaration.option` method.

## 0.5.2

### New features

- Add `raise_errors` option to `EventSource.on` method.

## 0.5.1

### Bug fixes

- Require `EventSource` by default.

## 0.5.0

### New features

- Add `EventSource` mixin.

## 0.4.0

### New features

- Add `before_success` and `before_error` callbacks to `ResultMonad`.

## 0.3.0

### New features

- Add `ResultMonad` mixin.

## 0.2.0

### New features

- Add `OptionsDeclaration` mixin.

## 0.1.1

### Bug fixes

- Require `FunctionalObject` by default.

## 0.1.0

### New features

- Add `FunctionalObject` mixin.
