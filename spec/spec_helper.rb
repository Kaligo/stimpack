# frozen_string_literal: true

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4.
    #
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true

    # We intentionally expect no error raised with a specific error class.
    #
    expectations.on_potential_false_positives = :nothing
  end

  config.mock_with :rspec do |mocks|
    # This option will default to `true` in RSpec 4.
    #
    mocks.verify_partial_doubles = true
  end

  # This option will default to `:apply_to_host_groups` in RSpec 4.
  #
  config.shared_context_metadata_behavior = :apply_to_host_groups

  # Limits the available syntax to the non-monkey patched syntax that is
  # recommended.
  #
  config.disable_monkey_patching!

  # This setting enables warnings. It's recommended, but in some cases may
  # be too noisy due to issues in dependencies.
  #
  config.warnings = true

  # Print the 10 slowest examples and example groups at the end of the spec
  # run, to help surface which specs are running particularly slow.
  #
  config.profile_examples = 10

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  #
  Kernel.srand config.seed
end
