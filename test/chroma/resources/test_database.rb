# frozen_string_literal: true

require "test_helper"

class DatabaseTest < Minitest::Test
  include StubRequest

  def setup
    @default_config = Chroma.config.dup

    Chroma.connect_host = "http://chroma-server.org"

    initialize_stub_store
  end

  def teardown
    Chroma.instance_variable_set(:@config, @default_config)

    clear_stub_store
  end

  def test_it_gets_database_server_version
    @stubs << stub_request(:get, "#{Chroma.api_url}/version").to_return(status: 200, body: "0.3.22", headers: {"Content-Type": "application/text"})

    version = Chroma::Resources::Database.version

    assert_equal "0.3.22", version
  end

  def test_it_gets_database_server_heartbeat
    @stubs << stub_request(:get, "#{Chroma.api_url}/heartbeat").to_return(status: 200, body: %({"nanosecond heartbeat": 1683757215667247439000}), headers: {"Content-Type": "application/text"})

    heartbeat = Chroma::Resources::Database.heartbeat

    assert_equal({"nanosecond heartbeat" => 1683757215667247439000}, heartbeat)
  end

  def test_it_persist_database_server_data
    @stubs << stub_request(:post, "#{Chroma.api_url}/persist").to_return(status: 200, body: "true", headers: {"Content-Type": "application/text"})

    persisted = Chroma::Resources::Database.persist

    assert persisted
  end

  def test_it_resets_database_server_data
    @stubs << stub_request(:post, "#{Chroma.api_url}/reset").to_return(status: 200, body: "true", headers: {"Content-Type": "application/text"})

    reseted = Chroma::Resources::Database.reset

    assert reseted
  end
end
