# frozen_string_literal: true

require "test_helper"

class CollectionTest < Minitest::Test
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

  def test_it_creates_a_collection
    body = request_body
    name = body.fetch(:name)
    metadata = body.fetch(:metadata)

    stub_collection_request(
      "#{Chroma.api_url}/collections",
      method: :post,
      request_body: body.merge(get_or_create: false),
      response_body: body
    )

    collection = Chroma::Resources::Collection.create_collection("test-collection", {source: "test"})

    assert_instance_of(Chroma::Resources::Collection, collection)
    assert_equal name, collection.name
    assert_equal deep_stringify_keys(metadata), collection.metadata
  end

  def test_it_raises_api_connection_error_with_network_problems
    stub_network_error("#{Chroma.api_url}/collections")

    assert_raises Chroma::APIConnectionError do
      Chroma::Resources::Collection.create_collection("test-collection", {source: "test"})
    end
  end

  def test_it_raises_invalid_request_error_with_invalid_parameters
    stub_server_error("#{Chroma.api_url}/collections", %({"error":"ValueError('Expected collection name that (1) contains 3-63 characters, (2) starts and ends with an alphanumeric character, (3) otherwise contains only alphanumeric characters, underscores or hyphens (-), (4) contains no two consecutive periods (..) and (5) is not a valid IPv4 address, got ruby-index-4 invalid')"}))

    assert_raises Chroma::InvalidRequestError do
      Chroma::Resources::Collection.create_collection("test-collection", {source: "test"})
    end
  end

  def test_it_raises_api_connection_error_with_server_problems
    stub_server_error("#{Chroma.api_url}/collections")

    assert_raises Chroma::APIConnectionError do
      Chroma::Resources::Collection.create_collection("test-collection", {source: "test"})
    end
  end

  def test_it_raises_api_error
    stub_client_error("#{Chroma.api_url}/collections")

    assert_raises Chroma::APIError do
      Chroma::Resources::Collection.create_collection("test-collection", {source: "test"})
    end
  end

  private

  def stub_collection_request(url, method: :get, status: 200, request_body: {}, response_body: {})
    @stubs << stub_request(method, url)
      .with(body: request_body.to_json)
      .to_return(status:, body: response_body.to_json, headers: {"Content-Type": "application/json"})
  end

  def request_body(attrs = {})
    {name: "test-collection", metadata: {source: "test"}}.deep_merge(attrs)
  end

  def deep_stringify_keys(hash)
    hash.each_with_object({}) do |(key, value), result|
      new_key = key.to_s
      new_value = value.is_a?(Hash) ? deep_stringify_keys(value) : value
      result[new_key] = new_value
    end
  end
end
