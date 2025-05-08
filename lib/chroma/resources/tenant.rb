# frozen_string_literal: true

module Chroma
  module Resources
    # A Tenant class represents a tenant  by its ID and name.
    class Tenant
      include Chroma::APIOperations::Request

      attr_reader :id
      attr_reader :name

      def initialize(id:, name:)
        @id = id
        @name = name
      end

      # Create a new tenant.
      #
      # name - The name of the tenant.
      #
      # Examples
      #
      #   tenant = Chorma::Resources::Tenant.create("tenant-name")
      #
      # Returns true if the tenant was successfully created, raises Chroma::APIError otherwise.
      def self.create(name)
        payload = {name: name}

        result = execute_request(:post, "#{Chroma.api_url}/tenants", payload)

        return true if result.success?

        raise_failure_error(result)
      end

      # Retrieves a tenant.
      #
      # tenant_name - The name of the tenant to retrieve.
      #
      # Examples
      #
      #   Chroma::Resources::Tenant.get("tenant-name")
      #
      # Returns The retrieved tenant object. Raises Chroma::APIError if not found.
      def self.get(tenant_name)
        result = execute_request(:get, "#{Chroma.api_url}/tenants/#{tenant_name}")

        if result.success?
          data = result.success.body
          new(id: data["id"], name: data["name"])
        else
          raise_failure_error(result)
        end
      end
    end
  end
end
