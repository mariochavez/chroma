# frozen_string_literal: true

module Chroma
  # The Util module provides utility methods for logging messages and data at different levels of severity.
  module Util
    # Logs an error message with the given data using the provided Logger instance.
    #
    # message - A String message to be logged.
    # data - A Hash of additional data to be included in the log entry.
    #
    # Examples
    #
    #   Util.log_error("An error occurred", { user_id: 123, error_code: "404" })
    #
    # Returns nothing.
    def self.log_error(message, data = {})
      config = data.delete(:config) || Chroma.config
      logger = config.logger || Chroma.logger

      if (!logger.nil? || !config.log_level.nil?) && config.log_level <= Chroma::LEVEL_ERROR
        log_internal(message, data, level: Chroma::LEVEL_ERROR, logger: Chroma.logger)
      end
    end

    # Logs a debug message with the given data using the provided Logger instance.
    #
    # message - A String message to be logged.
    # data - A Hash of additional data to be included in the log entry.
    #
    # Examples
    #
    #   Util.log_debug("Debugging information", { user_id: 123, action: "update" })
    #
    # Returns nothing.
    def self.log_debug(message, data = {})
      config = data.delete(:config) || Chroma.config
      logger = config.logger || Chroma.logger

      if (!logger.nil? || !config.log_level.nil?) && config.log_level <= Chroma::LEVEL_DEBUG
        log_internal(message, data, level: Chroma::LEVEL_DEBUG, logger: Chroma.logger)
      end
    end

    # Logs an informational message with the given data using the provided Logger instance.
    #
    # message - A String message to be logged.
    # data - A Hash of additional data to be included in the log entry.
    #
    # Examples
    #
    #   Util.log_info("Processing request", { request_id: "abc123", route: "/users" })
    #
    # Returns nothing.
    def self.log_info(message, data = {})
      config = data.delete(:config) || Chroma.config
      logger = config.logger || Chroma.logger

      if (!logger.nil? || !config.log_level.nil?) && config.log_level <= Chroma::LEVEL_INFO
        log_internal(message, data, level: Chroma::LEVEL_INFO, logger: Chroma.logger)
      end
    end

    def self.log_internal(message, data = {}, level:, logger:)
      data_str = data.reject { |_k, v| v.nil? }.map { |(k, v)| "#{k}=#{v}" }.join(" ")

      logger&.add(level, "message=#{message} #{data_str}".strip)
    end
    private_class_method :log_internal
  end
end
