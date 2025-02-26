# frozen_string_literal: true

require_relative "gdocs/version"

require "gdocs/config"
require "gdocs/models/document"
require "gdocs/models/spreadsheet"
require "gdocs/models/presentation"

module Gdocs
  class Error < StandardError; end

end
