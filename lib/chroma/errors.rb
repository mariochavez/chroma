# frozen_string_literal: true

module Chroma
  # ChromaError is the base error from which all other more specific Chrome
  # errors derive.
  class ChromaError < StandardError
    attr_accessor :response

    attr_reader :message
    attr_reader :error
    attr_reader :body
    attr_reader :status

    def initialize(message = nil, status: nil, body: nil, response: nil)
      @message = message
      @status = status
      @body = body
      @response = response
    end

    def to_s
      status_value = @status.nil? ? "" : "(Status #{@status}) "
      "#{status_value}#{@message}"
    end
  end

  # APIConnectionError is raised in the event that the SDK can't connect to
  # Chroma's database. That can be for a variety of different reasons from a
  # downed network to a bad TLS certificate.
  class APIConnectionError < ChromaError
  end

  # InvalidRequestError is raised when a request is initiated with invalid
  # parameters.
  class InvalidRequestError < ChromaError
    def initialize(message = nil, status: nil, body: nil, response: nil)
      super

      decode_message
    end

    private

    def decode_message
      if message.include?("ValueError")
        error = JSON.parse(message)
        value = error.fetch("error", "").sub("ValueError('", "").sub("')", "")
        @message = value if !value.nil?
      end
    rescue JSON::ParserError, TypeError
    end
  end

  # APIError is a generic error that may be raised in cases where none of the
  # other named errors cover the problem.
  class APIError < ChromaError
    def initialize(message = nil, status: nil, body: nil, response: nil)
      super

      decode_message
    end

    private

    def decode_message
      if message.is_a?(Hash) && message.has_key?("error")
        @message = message.fetch("error")
      end
    end
  end
end
