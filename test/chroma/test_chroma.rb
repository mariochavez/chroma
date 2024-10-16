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

  def test_it_allows_to_set_api_key
    api_key = "1234abcd"
    Chroma.api_key = api_key

    assert_equal(api_key, Chroma.api_key)
  end

  def test_it_allows_to_set_tenant_and_database
    assert_equal("default_tenant", Chroma.tenant)
    assert_equal("default_database", Chroma.database)

    tenant = "test_tenant"
    database = "test_database"

    Chroma.tenant = tenant
    Chroma.database = database

    assert_equal(tenant, Chroma.tenant)
    assert_equal(database, Chroma.database)
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

  def test_it_sets_default_database_and_tenant_when_api_key_is_not_set
    Chroma.connect_host = "https://chroma-server.org"
    Chroma.api_key = nil

    assert_equal("https://chroma-server.org/api/v1", Chroma.api_url)
  end
end
