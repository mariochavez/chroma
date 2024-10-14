# frozen_string_literal: true

module Chroma
  # The ChromaConfiguration class allows you to configure the connection settings for a Chroma service client.
  # It can be initialized directly calling #new method.
  #
  # Examples
  #
  #   configuration = Chroma::ChromaConfiguration.new
  #   configurarion.connect_host = "https://chroma.example.com"
  #
  # Or via a setup block.
  #
  # Examples
  #
  #   Chroma::ChromaConfiguration.setup do |config|
  #     config.connect_host = "https://chroma.example.com"
  #   end
  class ChromaConfiguration
    # Sets the host name for the Chroma service.
    #
    # Examples
    #
    #   config.connect_host = "chroma.example.com"
    #
    # Returns the String host name.
    attr_accessor :connect_host

    # Sets the tenant for the Chroma service, Defaults to 'default_tenant'.
    #
    # Examples
    #
    #   config.tenant = "my_tenant"
    #
    # Returns the String tenant.
    attr_accessor :tenant

    # Sets the database for the Chroma service, Defaults to 'default_database'.
    #
    # Examples
    #
    #   config.database = "my_database"
    #
    # Returns the String database.
    attr_accessor :database

    # Sets the API Key for the Chroma service, for `x-chroma-token` header.
    #
    # Examples
    #
    #   config.api_key = "1234abcd"
    #
    # Returns the String database.
    attr_accessor :api_key

    # Sets the base path for the Chroma API.
    #
    # Examples
    #
    #   config.api_base = "/api"
    #
    # Returns the String API base path.
    attr_accessor :api_base
    # Sets the version of the Chroma API.
    #
    # Examples
    #
    #   config.api_version = "v1"
    #
    # Returns the String API version.
    attr_accessor :api_version
    # Sets the logger for the Chroma service client.
    #
    # Examples
    #
    #   config.logger = Logger.new(STDOUT)
    #
    # Returns the Logger instance.
    attr_accessor :logger
    # Sets the logger's log level for the Chroma service client.
    #
    # Examples
    #
    #   config.log_level = Chroma::LEVEL_INFO
    #
    # Returns the log level constant
    attr_accessor :log_level

    def self.setup
      new.tap do |instance|
        yield(instance) if block_given?
      end
    end

    def initialize
      @api_base = "api"
      @api_version = "v1"

      @log_level = Chroma::LEVEL_INFO

      @tenant ||= "default_tenant"
      @database ||= "default_database"
    end
  end
end
