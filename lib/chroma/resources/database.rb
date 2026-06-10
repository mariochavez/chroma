# frozen_string_literal: true

module Chroma
  module Resources
    # The Database class provides methods for interacting with the Chroma database server.
    class Database
      using RubyNext

      include Chroma::APIOperations::Request

      attr_reader :id
      attr_reader :name
      attr_reader :tenant

      def initialize(id:, name:, tenant:)
        @id = id
        @name = name
        @tenant = tenant
      end

      # Get the current user's identity, tenant, and databases of the Chroma database server.
      #
      # Returns the current user's identity, tenant, and databases of the Chroma database server.
      def self.auth_identity
        result = execute_request(:get, "#{Chroma.api_url}/auth/identity")

        return result.success.body if result.success?

        raise_failure_error(result)
      end

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

      # Check the hearlthcheck of the Chroma database server.
      #
      # Return a Hash with a boolean.
      def self.healthcheck
        result = execute_request(:get, "#{Chroma.api_url}/healthcheck")

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

      # Check the pre-flight checks of the Chroma database server.
      #
      # Return a Hash with a timestamp.
      def self.pre_flight_checks
        result = execute_request(:get, "#{Chroma.api_url}/pre-flight-checks")

        return result.success.body if result.success?

        raise_failure_error(result)
      end

      # Lists all databases from the tenant.
      #
      # Examples
      #
      #   Chroma::Resources::Database.list
      #
      # Returns an array of all databases in the tenant.
      def self.list
        result = execute_request(:get, "#{Chroma.api_url}/tenants/#{Chroma.tenant}/databases")

        if result.success?
          data = result.success.body
          data.map { |item| new(id: item["id"], name: item["name"], tenant: item["tenant"]) }
        else
          raise_failure_error(result)
        end
      end

      # Create a new database on the tenant.
      #
      # name - The name of the database.
      #
      # Examples
      #
      #   database = Chorma::Resources::Database.create("database-name")
      #
      # Returns true if the database was successfully created, raises Chroma::APIError otherwise.
      def self.create(name)
        payload = {name: name}

        result = execute_request(:post, "#{Chroma.api_url}/tenants/#{Chroma.tenant}/databases", payload)

        return true if result.success?

        raise_failure_error(result)
      end

      # Retrieves a database from the tenant.
      #
      # database_name - The name of the database to retrieve.
      #
      # Examples
      #
      #   Chroma::Resources::Database.get("database-name")
      #
      # Returns The retrieved database object. Raises Chroma::APIError if not found.
      def self.get(database_name)
        result = execute_request(:get, "#{Chroma.api_url}/tenants/#{Chroma.tenant}/databases/#{database_name}")

        if result.success?
          data = result.success.body
          new(id: data["id"], name: data["name"], tenant: data["tenant"])
        else
          raise_failure_error(result)
        end
      end

      # Deletes a database from the tenant.
      #
      # database_name - The name of the database to retrieve.
      #
      # Examples
      #
      #   Chroma::Resources::Database.delete("database-name")
      #
      # Returns true if the database was successfully deleted, raises Chroma::APIError otherwise.
      def self.delete(database_name)
        result = execute_request(:delete, "#{Chroma.api_url}/tenants/#{Chroma.tenant}/databases/#{database_name}")

        return true if result.success?

        raise_failure_error(result)
      end

      # Count the total number of collections in the database object.
      #
      # Examples
      #
      #   database = Chroma::Resources::Database.get("database-name")
      #   database.collections_count
      #
      # Returns the count of collections in the database.
      def collections_count
        result = self.class.execute_request(:get, "#{Chroma.api_url}/tenants/#{Chroma.tenant}/databases/#{name}/collections_count")

        return result.success.body if result.success?

        self.class.raise_failure_error(result)
      end
    end
  end
end
