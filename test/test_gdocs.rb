# frozen_string_literal: true

require "test_helper"

class TestGdocs < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Gdocs::VERSION
  end

  def test_it_does_something_useful
    assert_equal "Hello, world!", Gdocs::Hello.hello, "Got different hello message"
  end
end
