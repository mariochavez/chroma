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

    collection = Chroma::Resources::Collection.create("test-collection", {source: "test"})

    assert_instance_of(Chroma::Resources::Collection, collection)
    assert_equal name, collection.name
    assert_equal deep_stringify_keys(metadata), collection.metadata
  end

  def test_it_raises_api_connection_error_with_network_problems_create_collection
    stub_network_error("#{Chroma.api_url}/collections")

    assert_raises Chroma::APIConnectionError do
      Chroma::Resources::Collection.create("test-collection", {source: "test"})
    end
  end

  def test_it_raises_invalid_request_error_with_invalid_parameters_create_collection
    stub_server_error("#{Chroma.api_url}/collections", %({"error":"ValueError('Expected collection name that (1) contains 3-63 characters, (2) starts and ends with an alphanumeric character, (3) otherwise contains only alphanumeric characters, underscores or hyphens (-), (4) contains no two consecutive periods (..) and (5) is not a valid IPv4 address, got ruby-index-4 invalid')"}))

    assert_raises Chroma::InvalidRequestError do
      Chroma::Resources::Collection.create("test-collection", {source: "test"})
    end
  end

  def test_it_raises_api_connection_error_with_server_problems_create_collection
    stub_server_error("#{Chroma.api_url}/collections")

    assert_raises Chroma::APIConnectionError do
      Chroma::Resources::Collection.create("test-collection", {source: "test"})
    end
  end

  def test_it_raises_api_error_create_collection
    stub_client_error("#{Chroma.api_url}/collections")

    assert_raises Chroma::APIError do
      Chroma::Resources::Collection.create("test-collection", {source: "test"})
    end
  end

  def test_it_gets_a_collection
    body = request_body
    name = body.fetch(:name)
    metadata = body.fetch(:metadata)

    stub_collection_request(
      "#{Chroma.api_url}/collections/#{name}",
      method: :get,
      request_body: "",
      response_body: body
    )

    collection = Chroma::Resources::Collection.get("test-collection")

    assert_instance_of(Chroma::Resources::Collection, collection)
    assert_equal name, collection.name
    assert_equal deep_stringify_keys(metadata), collection.metadata
  end

  def test_it_raises_invalid_request_error_with_invalid_name_get_collection
    body = request_body
    name = body.fetch(:name)

    stub_server_error("#{Chroma.api_url}/collections/#{name}", %({"error"=>"ValueError('Collection #{name} does not exist')"}))

    assert_raises Chroma::InvalidRequestError do
      Chroma::Resources::Collection.get("test-collection")
    end
  end

  def test_it_gets_a_collection_list
    body = request_body

    stub_collection_request(
      "#{Chroma.api_url}/collections",
      method: :get,
      request_body: "",
      response_body: [body]
    )

    collections = Chroma::Resources::Collection.list

    assert_instance_of(Chroma::Resources::Collection, collections.first)
    assert_equal 1, collections.size
  end

  def test_it_deletes_collection
    body = request_body
    name = body.fetch(:name)

    stub_collection_request(
      "#{Chroma.api_url}/collections/#{name}",
      method: :delete,
      request_body: "",
      response_body: [body]
    )

    deleted = Chroma::Resources::Collection.delete("test-collection")

    assert deleted
  end

  def test_it_raises_invalid_request_error_deleting_not_existing_collection
    body = request_body
    name = body.fetch(:name)

    stub_server_error("#{Chroma.api_url}/collections/#{name}", %({"error"=>"IndexError('list index out of range')"}))

    assert_raises Chroma::InvalidRequestError do
      Chroma::Resources::Collection.delete("test-collection")
    end
  end

  def test_it_modifies_collection
    body = request_body
    name = body.fetch(:name)
    metadata = body.fetch(:metadata)

    stub_collection_request(
      "#{Chroma.api_url}/collections/#{name}",
      method: :put,
      request_body: {new_name: "new-collection-name", new_metadata: {source: "test"}}
    )

    collection = Chroma::Resources::Collection.new(name: name, metadata: metadata)

    deleted = collection.modify("new-collection-name", new_metadata: {source: "test"})

    assert deleted
  end

  def test_it_counts_collection_embeddings
    body = request_body
    name = body.fetch(:name)
    metadata = body.fetch(:metadata)

    stub_collection_request(
      "#{Chroma.api_url}/collections/#{name}/count",
      method: :get,
      request_body: "",
      response_body: 1
    )

    collection = Chroma::Resources::Collection.new(name: name, metadata: metadata)

    count = collection.count

    assert_equal 1, count
  end

  def test_it_adds_embeddings_to_collection
    embeddings = [
      Chroma::Resources::Embedding.new(id: "pdf-1", embedding: [1.5, 2.9, 3.4], metadata: {source: "Test"}, document: "Content file 1"),
      Chroma::Resources::Embedding.new(id: "pdf-2", embedding: [9.8, 2.3, 2.9], metadata: {source: "Test"}, document: "Content file 2")
    ]
    body = request_body(
      ids: embeddings.map(&:id),
      embeddings: embeddings.map(&:embedding),
      metadatas: embeddings.map(&:metadata),
      documents: embeddings.map(&:document)
    )
    name = body.delete(:name)
    metadata = body.delete(:metadata)

    stub_collection_request(
      "#{Chroma.api_url}/collections/#{name}/add",
      method: :post,
      request_body: body.merge(increment_index: true),
      response_body: true
    )

    collection = Chroma::Resources::Collection.new(name: name, metadata: metadata)

    added = collection.add(embeddings)

    assert added
  end

  def test_it_updates_embeddings_to_collection
    embeddings = [
      Chroma::Resources::Embedding.new(id: "pdf-1", embedding: [1.5, 2.9, 3.4], metadata: {source: "Test"}, document: "Content file 1"),
      Chroma::Resources::Embedding.new(id: "pdf-2", embedding: [9.8, 2.3, 2.9], metadata: {source: "Test"}, document: "Content file 2")
    ]
    body = request_body(
      ids: embeddings.map(&:id),
      embeddings: embeddings.map(&:embedding),
      metadatas: embeddings.map(&:metadata),
      documents: embeddings.map(&:document)
    )
    name = body.delete(:name)
    metadata = body.delete(:metadata)

    stub_collection_request(
      "#{Chroma.api_url}/collections/#{name}/update",
      method: :post,
      request_body: body,
      response_body: true
    )

    collection = Chroma::Resources::Collection.new(name: name, metadata: metadata)

    updated = collection.update(embeddings)

    assert updated
  end

  def test_it_upsert_embeddings_to_collection
    embeddings = [
      Chroma::Resources::Embedding.new(id: "pdf-1", embedding: [1.5, 2.9, 3.4], metadata: {source: "Test"}, document: "Content file 1"),
      Chroma::Resources::Embedding.new(id: "pdf-2", embedding: [9.8, 2.3, 2.9], metadata: {source: "Test"}, document: "Content file 2")
    ]
    body = request_body(
      ids: embeddings.map(&:id),
      embeddings: embeddings.map(&:embedding),
      metadatas: embeddings.map(&:metadata),
      documents: embeddings.map(&:document)
    )
    name = body.delete(:name)
    metadata = body.delete(:metadata)

    stub_collection_request(
      "#{Chroma.api_url}/collections/#{name}/upsert",
      method: :post,
      request_body: body.merge(increment_index: true),
      response_body: true
    )

    collection = Chroma::Resources::Collection.new(name: name, metadata: metadata)

    upserted = collection.upsert(embeddings)

    assert upserted
  end

  def test_it_gets_embeddings_from_collection
    embeddings = [
      Chroma::Resources::Embedding.new(id: "pdf-1", embedding: [1.5, 2.9, 3.4], metadata: {source: "Test"}, document: "Content file 1"),
      Chroma::Resources::Embedding.new(id: "pdf-2", embedding: [9.8, 2.3, 2.9], metadata: {source: "Test"}, document: "Content file 2")
    ]

    body = {
      ids: embeddings.map(&:id),
      where: {},
      sort: nil,
      limit: nil,
      offset: nil,
      where_document: {},
      include: %w[metadatas documents]
    }
    name = "test-collection"

    stub_collection_request(
      "#{Chroma.api_url}/collections/#{name}/get",
      method: :post,
      request_body: body,
      response_body: {
        ids: embeddings.map(&:id),
        embeddings: embeddings.map(&:embedding),
        metadatas: embeddings.map(&:metadata),
        documents: embeddings.map(&:document)
      }
    )

    collection = Chroma::Resources::Collection.new(name: name)

    result_embeddings = collection.get(ids: body.fetch(:ids))

    assert_equal 2, result_embeddings.size
    assert_equal "pdf-1", result_embeddings[0].id
  end

  def test_it_deletes_embeddings_from_collection
    embeddings = [
      Chroma::Resources::Embedding.new(id: "pdf-1", embedding: [1.5, 2.9, 3.4], metadata: {source: "Test"}, document: "Content file 1"),
      Chroma::Resources::Embedding.new(id: "pdf-2", embedding: [9.8, 2.3, 2.9], metadata: {source: "Test"}, document: "Content file 2")
    ]

    body = {
      ids: embeddings.map(&:id),
      where: {},
      where_document: {}
    }
    name = "test-collection"

    stub_collection_request(
      "#{Chroma.api_url}/collections/#{name}/delete",
      method: :post,
      request_body: body,
      response_body: ["7d993230-c215-40c3-ad23-d8a80bcffca1", "28b1da30-6fab-4cce-9969-3f3fed24df0a"]
    )

    collection = Chroma::Resources::Collection.new(name: name)

    deleted_embeddings = collection.delete(ids: body.fetch(:ids))

    assert_equal 2, deleted_embeddings.size
  end

  def test_it_create_an_index_for_a_collection
    name = "test-collection"

    stub_collection_request(
      "#{Chroma.api_url}/collections/#{name}/create_index",
      method: :post,
      request_body: "",
      response_body: true
    )

    collection = Chroma::Resources::Collection.new(name: name)
    result = collection.create_index

    assert result
  end

  private

  def stub_collection_request(url, method: :get, status: 200, request_body: {}, response_body: {})
    @stubs << stub_request(method, url)
      .with(body: request_body.is_a?(Hash) ? request_body.to_json : request_body)
      .to_return(status:, body: response_body.to_json, headers: {"Content-Type": "application/json"})
  end

  def request_body(attrs = {})
    {name: "test-collection", metadata: {source: "test"}}.merge(attrs)
  end

  def deep_stringify_keys(hash)
    hash.each_with_object({}) do |(key, value), result|
      new_key = key.to_s
      new_value = value.is_a?(Hash) ? deep_stringify_keys(value) : value
      result[new_key] = new_value
    end
  end
end
