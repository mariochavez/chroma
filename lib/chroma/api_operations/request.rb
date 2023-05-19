# frozen_string_literal: true

module Chroma
  module APIOperations
    using RubyNext

    # Request's response Data object.
    #
    # status - HTTP status code. It is zero when a request fails due to network error.
    # body - Parsed JSON object or response body.
    # headers - HTTP response headers.
    # error - Exception or Net::HTTPResponse object if the response is not Net::HTTPSuccess
    Response = Data.define(:status, :body, :headers, :error)

    # Request module provides functionality to perform HTTP requests.
    module Request
      module ClassMethods
        include Dry::Monads[:result]

        # Execute an HTTP request and return a monad wrapping the response.
        #
        # method - The HTTP method to use (e.g. 'GET', 'POST'). Method must be a `Symbol`.
        # url - The URL to send the request to.
        # params - The query parameters or request body. Params needs to be in a form of a Hash.
        # options - Additional options to pass to the request.
        #
        # A `Dry::Monads::Result` monad wrapping the response, either a success or failure.
        # The response is a `Chroma::APIOperations::Response` Data object.
        #
        # Examples
        #
        #   result = execute_request(:get, "https://example.com", {name: "test request"})
        #   if result.success?
        #     puts "Response status: #{result.success.status}"
        #     puts "Response body: #{result.success.body}"
        #   else
        #     puts "Request failed with error: #{result.failure.error}"
        #   end
        def execute_request(method, url, params = {}, options = {})
          uri = URI.parse(url)

          request = build_request(method, uri, params)

          use_ssl = options.delete(:use_ssl) || false
          response = Net::HTTP.start(uri.hostname, uri.port, use_ssl:) do |http|
            Chroma::Util.log_debug("Sending a request", {method:, uri:, params:})
            http.request(request)
          end

          build_response(response)
        rescue => ex
          build_response(ex)
        end

        private def build_response(response)
          case response
          in Net::HTTPSuccess => success_response
            Chroma::Util.log_info("Successful response", code: success_response.code)

            build_response_details(success_response)
          in Net::HTTPRedirection => redirect_response
            Chroma::Util.log_info("Server redirect response", code: redirect_response.code, location: redirect_response["location"])

            build_response_details(redirect_response)
          in Net::HTTPClientError => client_error_response
            Chroma::Util.log_error("Client error response", code: client_error_response.code, body: client_error_response.body)

            build_response_details(client_error_response)
          in Net::HTTPServerError => server_error_response
            Chroma::Util.log_error("Server error response", code: server_error_response.code)

            build_response_details(server_error_response, parse_body: false)
          else
            Chroma::Util.log_error("An error happened", error: response.to_s)

            build_response_details(response, exception: true, parse_body: false)
          end
        end

        private def build_response_details(response, exception: false, parse_body: true)
          response_data = Chroma::APIOperations::Response.new(
            status: exception ? 0 : response.code.to_i,
            body: if exception
                    exception.to_s
                  else
                    (parse_body ? body_to_json(response.body) : response.body)
                  end,
            headers: exception ? {} : response.each_header.to_h,
            error: response.is_a?(Net::HTTPSuccess) ? nil : response
          )

          case response
          in Net::HTTPSuccess
            return Success(response_data)
          else
            return Failure(response_data)
          end
        end

        private def body_to_json(content)
          JSON.parse(content, symbolize_keys: true)
        rescue JSON::ParserError, TypeError
          content
        end

        private def build_request(method, uri, params)
          request = case method
          when :post then Net::HTTP::Post.new(uri)
          when :put then Net::HTTP::Put.new(uri)
          when :delete then Net::HTTP::Delete.new(uri)
          else
            Net::HTTP::Get.new(uri)
          end

          request.content_type = "application/json"
          request.body = params.to_json if params.size > 0

          request
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end
    end
  end
end
