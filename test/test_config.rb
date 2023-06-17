require 'test_helper'

class TestGdocsConfiguration < Minitest::Test

  # without an environment variable GDOCS_CLIENT_ID
  def test_client_id_without_env_variable
    ENV['GDOCS_CLIENT_ID'] = nil
    @config = Gdocs::Configuration.new
    assert_nil @config.client_id
  end

  # given an environment variable GDOCS_CLIENT_ID
  def test_client_id_env_variable_given
    @client_id = '236011090214-lak27p8vsgi0lvi1endr21v2jhpljajc.apps.googleusercontent.com'
    ENV['GDOCS_CLIENT_ID'] = @client_id
    @config = Gdocs::Configuration.new
    assert_equal @client_id, @config.client_id
  end

  # 'without an environment variable GDOCS_CLIENT_SECRET'
  def test_client_secret_without_env_variable
    ENV['GDOCS_CLIENT_SECRET'] = nil
    @config = Gdocs::Configuration.new
    assert_nil @config.client_secret
  end

  # given an environment variable GDOCS_CLIENT_SECRET
  def test_client_secret_env_variable_given
    @client_secret = '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'
    ENV['GDOCS_CLIENT_SECRET'] = @client_secret
    @config = Gdocs::Configuration.new
    assert_equal @client_secret, @config.client_secret
  end
end
