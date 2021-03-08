# frozen_string_literal: true

require_relative "lib/stimpack/version"

Gem::Specification.new do |spec|
  spec.version = Stimpack::VERSION
  spec.license = "MIT"

  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.name    = "stimpack"
  spec.authors = ["Ted Johansson"]
  spec.email   = ["ted.johansson@ascendaloyalty.com"]

  spec.summary     = "Supporting libraries for NydusNetwork."
  spec.description = "Supporting libraries for NydusNetwork."
  spec.homepage    = "https://www.github.com/kaligo/stimpack"

  spec.metadata["allowed_push_host"] = "nil"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  #
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end

  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{\Abin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rspec", "~> 3.10"
  spec.add_development_dependency "rubocop", "~> 1.11"
end
