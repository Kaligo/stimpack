# frozen_string_literal: true

require_relative "stimpack/version"

require_relative "stimpack/functional_object"
require_relative "stimpack/options_declaration"
require_relative "stimpack/result_monad"

module Stimpack
  class Error < StandardError; end
end
