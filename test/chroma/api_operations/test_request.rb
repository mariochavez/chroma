# frozen_string_literal: true

require "test_helper"

class RequestTest < Minitest::Test
  include StubRequest

  def setup
    @default_config = Chroma.config.dup

    Chroma.connect_host = "http://test.example.org"
    Chroma.log_level = Chroma::LEVEL_DEBUG

    @url = Chroma.api_url

    initialize_stub_store
  end

  def teardown
    Chroma.instance_variable_set(:@config, @default_config)

    clear_stub_store
  end

  def test_it_handles_server_error_from_request
    url = "#{@url}/collection"
    stub_server_error(url)
    subject = Class.new.include(Chroma::APIOperations::Request)

    response = subject.execute_request(:get, url)

    assert response.failure?
    assert_equal(500, response.failure.status)
  end

  def test_it_handles_server_redirect_from_request
    url = "#{@url}/collection"
    stub_server_redirect(url)
    subject = Class.new.include(Chroma::APIOperations::Request)

    response = subject.execute_request(:get, url)

    assert response.failure?
    assert_equal(301, response.failure.status)
  end

  def test_it_handles_client_error_from_request
    url = "#{@url}/collection"
    stub_client_error(url)
    subject = Class.new.include(Chroma::APIOperations::Request)

    response = subject.execute_request(:get, url)

    assert response.failure?
    assert_equal(400, response.failure.status)
  end

  def test_it_handles_network_error_from_request
    url = "#{@url}/collection"
    stub_network_error(url)
    subject = Class.new.include(Chroma::APIOperations::Request)

    response = subject.execute_request(:get, url)

    assert response.failure?
    assert_equal(0, response.failure.status)
  end

  def test_it_handles_successuful_request
    url = "#{@url}/collection"
    stub_successful_request(url)
    subject = Class.new.include(Chroma::APIOperations::Request)

    response = subject.execute_request(:get, url)

    assert response.success?
    assert_equal(200, response.success.status)
  end

  def test_it_adds_api_key_to_request
    Chroma.api_key = "1234abcd"

    url = "#{@url}/collection"
    stub_successful_request(url, {tenant: Chroma.tenant, database: Chroma.database, "X-Chroma-Token": Chroma.api_key})
    subject = Class.new.include(Chroma::APIOperations::Request)

    response = subject.execute_request(:get, url)

    assert response.success?
  end
end
