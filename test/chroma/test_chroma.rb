# frozen_string_literal: true

require "test_helper"

class ChromaTest < Minitest::Test
  def setup
    @default_config = Chroma.config.dup
  end

  def teardown
    Chroma.instance_variable_set(:@config, @default_config)
  end

  def test_it_has_a_version_number
    refute_nil Chroma::VERSION
  end

  def test_it_allows_connect_host_configuration
    Chroma.connect_host = "https://chroma-server.org"
    assert_equal("https://chroma-server.org", Chroma.connect_host)
  end

  def test_it_allows_api_base_configuration
    Chroma.api_base = "other/api"
    assert_equal("other/api", Chroma.api_base)
  end

  def test_it_allows_api_version_configuration
    Chroma.api_version = "v2"
    assert_equal("v2", Chroma.api_version)
  end

  def test_it_build_an_url_with_api_url
    Chroma.connect_host = "https://chroma-server.org"
    Chroma.api_base = "other/api"
    Chroma.api_version = "v2"

    assert_equal("https://chroma-server.org/other/api/v2", Chroma.api_url)
  end

  def test_it_allows_log_level_configuration
    Chroma.log_level = 0
    assert_equal ::Logger::DEBUG, Chroma.log_level
  end

  def test_it_allows_logger_configuration
    logger = Object.new
    Chroma.logger = logger
    assert_equal logger, Chroma.logger
  end
end
