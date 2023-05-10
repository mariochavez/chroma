# frozen_string_literal: true

require "dry-monads"
require "logger"
require "forwardable"

require_relative "chroma/version"
require_relative "chroma/util"
require_relative "chroma/chroma_configuration"
require_relative "chroma/api_operations/request"
require_relative "chroma/errors"
require_relative "chroma/resources/embedding"
require_relative "chroma/resources/collection"

module Chroma
  # map to the same values as the standard library's logger
  LEVEL_DEBUG = Logger::DEBUG
  LEVEL_ERROR = Logger::ERROR
  LEVEL_INFO = Logger::INFO

  @config = Chroma::ChromaConfiguration.setup

  class << self
    extend Forwardable

    attr_reader :config

    # User configuration options
    def_delegators :@config, :connect_host, :connect_host=
    def_delegators :@config, :api_base, :api_base=
    def_delegators :@config, :api_version, :api_version=
    def_delegators :@config, :log_level, :log_level=
    def_delegators :@config, :logger, :logger=
  end

  def self.api_url
    "#{connect_host}/#{api_base}/#{api_version}"
  end

  Chroma.log_level = ENV["CHROMA_LOG"].to_i unless ENV["CHROMA_LOG"].nil?
end
