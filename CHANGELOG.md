# Changelog

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
