# frozen_string_literal: true

require "test_helper"

class TestGdocs < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Gdocs::VERSION
  end

  def test_document_has_a_title
    d = Gdocs::Models::Document.new('1IlgYRWw2Vo4DJLYg53_AyZxWeFsgohoV-wZ_pdWLBio')
    d.data = {"title" => "Untitled Document"}
    assert_equal "Untitled Document", d.title, "Got different document title"
  end
end
