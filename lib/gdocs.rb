# frozen_string_literal: true

require_relative "gdocs/version"

module Gdocs
  class Error < StandardError; end
  
  class Hello
    def self.hello
      "Hello, world!"
    end
  end
end
