# frozen_string_literal: true

module Chroma
  module Resources
    # The Database class provides methods for interacting with the Chroma database server.
    class Database
      include Chroma::APIOperations::Request
      # Get the version of the Chroma database server.
      #
      # Returns the version of the Chroma database server.
      def self.version
        result = execute_request(:get, "#{Chroma.api_url}/version")

        return result.success.body if result.success?

        raise_failure_error(result)
      end

      # Reset the Chroma database server. This can't be undone.
      #
      # Returns true on success or raise a Chroma::Error on failure.
      def self.reset
        result = execute_request(:post, "#{Chroma.api_url}/reset")

        return result.success.body if result.success?

        raise_failure_error(result)
      end

      # Persist Chroma database data.
      #
      # Resturn true on success or raise a Chroma::Error on failure.
      def self.persist
        result = execute_request(:post, "#{Chroma.api_url}/persist")

        return result.success.body if result.success?

        raise_failure_error(result)
      end

      # Check the heartbeat of the Chroma database server.
      #
      # Return a Hash with a timestamp.
      def self.heartbeat
        result = execute_request(:get, "#{Chroma.api_url}/heartbeat")

        return result.success.body if result.success?

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
    end
  end
end
