# frozen_string_literal: true

module Chroma
  module Resources
    class Collection
      include Chroma::APIOperations::Request

      attr_accessor :name
      attr_accessor :metadata

      def initialize(name, metadata)
        @name = name
        @metadata = metadata
      end

      def self.create(name, metadata = nil)
        payload = {name:, metadata:, get_or_create: false}

        result = execute_request(:post, "#{Chroma.api_url}/collections", payload)

        if result.success?
          data = result.success.body
          new(data["name"], data["metadata"])
        else
          raise_failure_error(result)
        end
      end

      def self.get(name)
        result = execute_request(:get, "#{Chroma.api_url}/collections/#{name}")

        if result.success?
          data = result.success.body
          new(data["name"], data["metadata"])
        else
          raise_failure_error(result)
        end
      end

      def self.list
        result = execute_request(:get, "#{Chroma.api_url}/collections")

        if result.success?
          data = result.success.body
          data.map { |item| new(item["name"], item["metadata"]) }
        else
          raise_failure_error(result)
        end
      end

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
          if response.body.is_a?(String) && (response.body.include?("ValueError") || response.body.include?("IndexError"))
            raise Chroma::InvalidRequestError.new(result.failure.body, status: result.failure.status, body: result.failure.body)
          else
            raise Chroma::APIConnectionError.new(result.failure.body, status: result.failure.status, body: result.failure.body)
          end
        else
          raise Chroma::APIError.new(result.failure.body, status: result.failure.status, body: result.failure.body)
        end
      end
      private_class_method :raise_failure_error
    end
  end
end
