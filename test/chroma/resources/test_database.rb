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

  def test_it_gets_database_server_auth_identity
    @stubs << stub_request(:get, "#{Chroma.api_url}/auth/identity").to_return(
      status: 200, body: %({"auth_identity": {"user_id": "", "tenant": "default_tenant", "databases": ["default_database"]}}), headers: {"Content-Type": "application/text"}
    )

    auth_identity = Chroma::Resources::Database.auth_identity

    assert_equal({"auth_identity" => {"user_id" => "", "tenant" => "default_tenant", "databases" => ["default_database"]}}, auth_identity)
  end

  def test_it_gets_database_server_version
    @stubs << stub_request(:get, "#{Chroma.api_url}/version").to_return(status: 200, body: "0.3.22", headers: {"Content-Type": "application/text"})

    version = Chroma::Resources::Database.version

    assert_equal "0.3.22", version
  end

  def test_it_gets_database_server_healthcheck
    @stubs << stub_request(:get, "#{Chroma.api_url}/healthcheck").to_return(status: 200, body: %({"is_executor_ready": true}), headers: {"Content-Type": "application/text"})

    healthcheck = Chroma::Resources::Database.healthcheck

    assert_equal({"is_executor_ready" => true}, healthcheck)
  end

  def test_it_gets_database_server_heartbeat
    @stubs << stub_request(:get, "#{Chroma.api_url}/heartbeat").to_return(status: 200, body: %({"nanosecond heartbeat": 1683757215667247439000}), headers: {"Content-Type": "application/text"})

    heartbeat = Chroma::Resources::Database.heartbeat

    assert_equal({"nanosecond heartbeat" => 1683757215667247439000}, heartbeat)
  end

  def test_it_gets_database_server_pre_flight_checks
    @stubs << stub_request(:get, "#{Chroma.api_url}/pre-flight-checks").to_return(status: 200, body: %({"max_batch_size": 5461}), headers: {"Content-Type": "application/text"})

    pre_flight_checks = Chroma::Resources::Database.pre_flight_checks

    assert_equal({"max_batch_size" => 5461}, pre_flight_checks)
  end

  def test_it_resets_database_server_data
    @stubs << stub_request(:post, "#{Chroma.api_url}/reset").to_return(status: 200, body: "true", headers: {"Content-Type": "application/text"})

    reseted = Chroma::Resources::Database.reset

    assert reseted
  end

  def test_it_counts_collection
    database_id = SecureRandom.uuid

    @stubs << stub_request(:get, "#{Chroma.api_url}/tenants/#{Chroma.tenant}/databases/#{Chroma.database}/collections_count").to_return(
      status: 200, body: "1", headers: {"Content-Type": "application/text"}
    )

    database = Chroma::Resources::Database.new(id: database_id, name: Chroma.database, tenant: Chroma.tenant)
    collections_count = database.collections_count

    assert_equal 1, collections_count
  end

  def test_it_lists_databases
    body = [{"id" => SecureRandom.uuid, "name" => "example_database", "tenant" => "example_tenant"}.to_json]

    @stubs << stub_request(:get, "#{Chroma.api_url}/tenants/#{Chroma.tenant}/databases").to_return(
      status: 200, body: body, headers: {"Content-Type": "application/text"}
    )

    databases = Chroma::Resources::Database.list

    assert_instance_of(Chroma::Resources::Database, databases.first)
    assert_equal 1, databases.size
  end

  def test_it_creates_a_database
    database_name = "new_database"

    @stubs << stub_request(:post, "#{Chroma.api_url}/tenants/#{Chroma.tenant}/databases").to_return(
      status: 200, body: "true", headers: {"Content-Type": "application/text"}
    )

    result = Chroma::Resources::Database.create(database_name)

    assert(result)
  end

  def test_it_retieves_a_database
    database_id = SecureRandom.uuid
    database_name = "new_database"
    database_tenant = Chroma.tenant

    @stubs << stub_request(:get, "#{Chroma.api_url}/tenants/#{database_tenant}/databases/#{database_name}").to_return(
      status: 200, body: %({"id": "#{database_id}", "name": "#{database_name}", "tenant": "#{Chroma.tenant}"}), headers: {"Content-Type": "application/text"}
    )

    database = Chroma::Resources::Database.get(database_name)

    assert_instance_of(Chroma::Resources::Database, database)
    assert_equal database_id, database.id
    assert_equal database_name, database.name
    assert_equal database_tenant, database.tenant
  end

  def test_it_deletes_a_database
    database_name = "new_database"

    @stubs << stub_request(:delete, "#{Chroma.api_url}/tenants/#{Chroma.tenant}/databases/#{database_name}").to_return(
      status: 200, body: "true", headers: {"Content-Type": "application/text"}
    )

    result = Chroma::Resources::Database.delete(database_name)

    assert(result)
  end
end
