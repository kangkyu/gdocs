module Gdocs
  # Provides methods to read and write config variables.
  #   Gdocs.configure do |config|
  #     config.client_id = '236011090214-lak27p8vsgi0lvi1endr21v2jhpljajc.apps.googleusercontent.com'
  #     config.client_secret = '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'
  #   end
  #
  # Note that Gdocs.configure has precedence over values through
  # GDOCS_CLIENT_ID or GDOCS_CLIENT_SECRET environment variables.
  #
  module Config
    # Yields the configuration to the given block.
    #
    # @yield [Gdocs::Configuration] The configuration.
    def configure
      yield configuration if block_given?
    end

    # Returns the {Gdocs::Configuration} object.
    #
    # @return [Gdocs::Configuration] The configuration.
    def configuration
      @configuration ||= Gdocs::Configuration.new
    end
  end

  # @note in order to have a syntax as easy as Gdocs.configure
  extend Config

  class Configuration
    # @return [String] the Client ID for Google clients.
    # @see https://console.developers.google.com
    attr_accessor :client_id

    # @return [String] the Client Secret for Google clients.
    # @see https://console.developers.google.com
    attr_accessor :client_secret

    attr_accessor :log_level

    def initialize
      @client_id = ENV['GDOCS_CLIENT_ID']
      @client_secret = ENV['GDOCS_CLIENT_SECRET']
      @log_level = ENV['GDOCS_LOG_LEVEL']
    end
  end
end
