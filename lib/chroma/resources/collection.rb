# frozen_string_literal: true

module Chroma
  module Resources
    # A Collection class represents a store for your embeddings, documents, and any additional metadata.
    # This class can be instantiated by receiving the collection's name and metadata hash.
    class Collection
      include Chroma::APIOperations::Request

      attr_reader :name
      attr_reader :metadata

      def initialize(name:, metadata: nil)
        @name = name
        @metadata = metadata
      end

      # Query the collection and return an array of embeddings.
      #
      # query_embeddings - An array of the embeddings to use for querying the collection.
      # results - The maximum number of results to return. 10 by default.
      # where - A Hash of additional conditions to filter the query results (optional).
      # where_document - A Hash of additional conditions to filter the associated documents (optional).
      # include  - An Array of the additional information to include in the query results (optional). Metadatas,
      #   documents, and distances by default.
      #
      # Examples
      #
      #   collection = Chroma::Resource::Collection.get("ruby-documentation")
      #   embeddings = collection.query(query_embeddings: [[1.5, 2.9, 3.3]], results: 5)
      #
      # Return an Array of Embedding with query results.
      def query(query_embeddings:, results: 10, where: {}, where_document: {}, include: %w[metadatas documents distances])
        payload = {
          query_embeddings:,
          n_results: results,
          where:,
          where_document:,
          include:
        }

        result = self.class.execute_request(:post, "#{Chroma.api_url}/collections/#{name}/query", payload)

        if result.success?
          build_embeddings_response(result.success.body)
        else
          raise_failure_error(result)
        end
      end

      # Get embeddings from the collection.
      #
      # ids - An Array of the specific embedding IDs to retrieve (optional).
      # where - A Hash of additional conditions to filter the query results (optional).
      # sort - The sorting criteria for the query results (optional).
      # limit - The maximum number of embeddings to retrieve (optional).
      # offset - The offset for pagination (optional).
      # page - The page number for pagination (optional).
      # page_size - The page size for pagination (optional).
      # where_document - A Hash of additional conditions to filter the associated documents (optional).
      # include - An Array of the additional information to include in the query results (optional). Metadatas,
      #   and documents by default.
      #
      # Examples
      #
      #   collection = Chroma::Resource::Collection.get("ruby-documentation")
      #   embeddings = collection.get([Array#sort, "Array#each"])
      #
      # Returns an Array of Embeddings
      def get(ids: nil, where: {}, sort: nil, limit: nil, offset: nil, page: nil, page_size: nil, where_document: {}, include: %w[metadatas documents])
        if !page.nil? && !page_size.nil?
          offset = (page - 1) * page_size
          limit = page_size
        end

        payload = {
          ids:,
          where:,
          sort:,
          limit:,
          offset:,
          where_document:,
          include:
        }

        result = self.class.execute_request(:post, "#{Chroma.api_url}/collections/#{name}/get", payload)

        if result.success?
          build_embeddings_response(result.success.body)
        else
          raise_failure_error(result)
        end
      end

      # Add one or many embeddings to the collection.
      #
      # embeddings - An Array of Embeddings or one Embedding to add.
      #
      # Examples
      #
      #   collection = Chroma::Resource::Collection.get("ruby-documentation")
      #   collection.add(Embedding.new(id: "Array#fetch", embeddings[9.8, 2.3, 2.9], metadata: {url: "https://..."}))
      #
      # Returns true with success or raises a Chroma::Error on failure.
      def add(embeddings = [])
        embeddings_array = Array(embeddings)
        return false if embeddings_array.size == 0

        payload = build_embeddings_payload(embeddings_array)

        result = self.class.execute_request(:post, "#{Chroma.api_url}/collections/#{name}/add", payload)

        return true if result.success?

        raise_failure_error(result)
      end

      # Delete embeddings from the collection.
      #
      # ids [Array<Integer>, nil] The specific embedding IDs to delete (optional).
      # where [Hash] Additional conditions to filter the embeddings to delete (optional).
      # where_document [Hash] Additional conditions to filter the associated documents (optional).
      #
      # Examples
      #
      #   collection = Chroma::Resource::Collection.get("ruby-documentation")
      #   collection.delete(["Array#fetch", "Array#sort"])
      #
      # Returns an Array of deleted global ids.
      def delete(ids: nil, where: {}, where_document: {})
        payload = {
          ids:,
          where:,
          where_document:
        }

        result = self.class.execute_request(:post, "#{Chroma.api_url}/collections/#{name}/delete", payload)

        return result.success.body if result.success?

        raise_failure_error(result)
      end

      # Update one or many embeddings to the collection.
      #
      # embeddings - An Array of Embeddings or one Embedding to add.
      #
      # Examples
      #
      #   collection = Chroma::Resource::Collection.get("ruby-documentation")
      #   collection.update(Embedding.new(id: "Array#fetch", embeddings[9.8, 2.3, 2.9], metadata: {url: "https://..."}))
      #
      # Returns true with success or raises a Chroma::Error on failure.
      def update(embeddings = [])
        embeddings_array = Array(embeddings)
        return false if embeddings_array.size == 0

        payload = build_embeddings_payload(embeddings_array)
        payload.delete(:increment_index)

        result = self.class.execute_request(:post, "#{Chroma.api_url}/collections/#{name}/update", payload)

        return true if result.success?

        raise_failure_error(result)
      end

      # Upsert (insert or update) one or many embeddings to the collection.
      #
      # embeddings - An Array of Embeddings or one Embedding to add.
      #
      # Examples
      #
      #   collection = Chroma::Resource::Collection.get("ruby-documentation")
      #   embeddings = [
      #     Embedding.new(id: "Array#fetch", embeddings[9.8, 2.3, 2.9], metadata: {url: "https://..."}),
      #     Embedding.new(id: "Array#select", embeddings[5.6, 3.1, 4.7], metadata: {url: "https://..."})
      #   ]
      #   collection.upsert()
      #
      # Returns true with success or raises a Chroma::Error on failure.
      def upsert(embeddings = [])
        embeddings_array = Array(embeddings)
        return false if embeddings_array.size == 0

        payload = build_embeddings_payload(embeddings_array)

        result = self.class.execute_request(:post, "#{Chroma.api_url}/collections/#{name}/upsert", payload)

        return true if result.success?

        raise_failure_error(result)
      end

      # Count the number of embeddings in a collection.
      #
      # Examples
      #
      #   collection = Chroma::Resource::Collection.get("ruby-documentation")
      #   collection.count
      #
      # Returns the count of embeddings in the collection.
      def count
        result = self.class.execute_request(:get, "#{Chroma.api_url}/collections/#{name}/count")

        return result.success.body if result.success?

        raise_failure_error(result)
      end

      # Modify the name and metadata of the current collection.
      #
      # new_name - The new name for the collection.
      # new_metadata - The new metadata hash for the collection.
      #
      # Examples:
      #
      #   collection = Chroma::Resource::Collection.get("ruby-documentation")
      #   collection.modify("ruby-3.2-documentation")
      #
      # Returns nothing.
      def modify(new_name, new_metadata: {})
        payload = {new_name:}
        payload[:new_metadata] = new_metadata if new_metadata.any?

        result = self.class.execute_request(:put, "#{Chroma.api_url}/collections/#{name}", payload)

        if result.success?
          @name = new_name
          @metadata = new_metadata
        else
          raise_failure_error(result)
        end
      end

      # Creates an index for the collection.
      #
      # Examples:
      #
      #   collection = Chroma::Resource::Collection.get("ruby-documentation")
      #   collection.create_index
      #
      # Returns true on success or raise a Chroma::Error on failure.
      def create_index
        result = self.class.execute_request(:post, "#{Chroma.api_url}/collections/#{name}/create_index")

        return true if result.success?

        raise_failure_error(result)
      end

      # Create a new collection on the database.
      #
      # name - The name of the collection. Name needs to be between 3-63 characters, starts and ends
      #   with an alphanumeric character, contains only alphanumeric characters, underscores or hyphens (-), and
      #   contains no two consecutive periods
      # metadata - A hash of additional metadata associated with the collection.
      #
      # Examples
      #
      #   collection = Chorma::Resources::Collection.create("ruby-documentation", {source: "Ruby lang website"})
      #
      # Returns the created collection object.
      def self.create(name, metadata = nil)
        payload = {name:, metadata:, get_or_create: false}

        result = execute_request(:post, "#{Chroma.api_url}/collections", payload)

        if result.success?
          data = result.success.body
          new(name: data["name"], metadata: data["metadata"])
        else
          raise_failure_error(result)
        end
      end

      # Retrieves a collection from the database.
      #
      # name - The name of the collection to retrieve.
      #
      # Examples
      #
      #   collection = Chroma::Resources::Colection.get("ruby-documentation")
      #
      # Returns The retrieved collection object. Raises Chroma::InvalidRequestError if not found.
      def self.get(name)
        result = execute_request(:get, "#{Chroma.api_url}/collections/#{name}")

        if result.success?
          data = result.success.body
          new(name: data["name"], metadata: data["metadata"])
        else
          raise_failure_error(result)
        end
      end

      # Retrieves all collections in the database.
      #
      # Examples
      #
      #   collections = Chroma::Resources::Collection.list
      #
      # Returns An array of all collections in the database.
      def self.list
        result = execute_request(:get, "#{Chroma.api_url}/collections")

        if result.success?
          data = result.success.body
          data.map { |item| new(name: item["name"], metadata: item["metadata"]) }
        else
          raise_failure_error(result)
        end
      end

      # Deletes a collection from the database.
      #
      # name - The name of the collection to delete.
      #
      # Examples
      #
      #   Chroma::Resources::Collection.delete("ruby-documentation")
      #
      # Returns true if the collection was successfully deleted, raise Chroma::InvalidRequestError otherwise.
      def self.delete(name)
        result = execute_request(:delete, "#{Chroma.api_url}/collections/#{name}")

        return true if result.success?

        raise_failure_error(result)
      end

      def self.raise_failure_error(result)
        case result.failure.error
        in Exception => exception
          raise Chroma::APIConnectionError.new(exception.message)
        in Net::HTTPInternalServerError => response
          if response.body.is_a?(String) && (response.body.include?("ValueError") || response.body.include?("IndexError") || response.body.include?("TypeError"))
            raise Chroma::InvalidRequestError.new(result.failure.body, status: result.failure.status, body: result.failure.body)
          else
            raise Chroma::APIConnectionError.new(result.failure.body, status: result.failure.status, body: result.failure.body)
          end
        else
          raise Chroma::APIError.new(result.failure.body, status: result.failure.status, body: result.failure.body)
        end
      end
      private_class_method :raise_failure_error

      private

      def build_embeddings_payload(embeddings, increment_index = true)
        payload = {ids: [], embeddings: [], metadatas: [], documents: [], increment_index: increment_index}

        embeddings.each do |embedding|
          payload[:ids] << embedding.id
          payload[:embeddings] << embedding.embedding
          payload[:metadatas] << embedding.metadata
          payload[:documents] << embedding.document
        end

        payload
      end

      def build_embeddings_response(result)
        Chroma::Util.log_debug("Building embeddings from #{result.inspect}")

        result_ids = result.fetch("ids", []).flatten
        result_embeddings = (result.dig("embeddings") || []).flatten
        result_documents = (result.dig("documents") || []).flatten
        result_metadatas = (result.dig("metadatas") || []).flatten
        result_distances = (result.dig("distances") || []).flatten

        Chroma::Util.log_debug("Ids #{result_ids.inspect}")
        Chroma::Util.log_debug("Embeddings #{result_embeddings.inspect}")
        Chroma::Util.log_debug("Documents #{result_documents.inspect}")
        Chroma::Util.log_debug("Metadatas #{result_metadatas.inspect}")
        Chroma::Util.log_debug("distances #{result_distances.inspect}")

        result_ids.map.with_index do |id, index|
          Chroma::Resources::Embedding.new(id: id, embedding: result_embeddings[index], document: result_documents[index], metadata: result_metadatas[index], distance: result_distances[index])
        end
      end
    end
  end
end
