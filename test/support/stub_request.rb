# frozen_string_literal: true

module StubRequest
  private

  def initialize_stub_store
    @stubs = []
  end

  def clear_stub_store
    @stubs.each { |stub| remove_request_stub(stub) }
  end

  def stub_server_error(url, message = "Internal Server Error")
    @stubs << stub_request(:any, url).to_return(status: 500, body: message)
  end

  def stub_server_redirect(url)
    @stubs << stub_request(:any, url).to_return(status: 301, headers: {"Location" => url})
  end

  def stub_client_error(url)
    @stubs << stub_request(:any, url).to_return(status: 400, body: %({"error": "Bad request"}))
  end

  def stub_network_error(url)
    @stubs << stub_request(:any, url).to_timeout
  end

  def stub_successful_request(url, query = {})
    @stubs << if query.empty?
      stub_request(:any, url)
        .to_return(status: 200, body: %({"name": "data-index"}), headers: {"Content-Type": "application/json"})
    else
      api_key = query.delete(:"X-Chroma-Token")
      stub_request(:any, url)
        .with(query: hash_including(query), headers: {"X-Chroma-Token": api_key})
        .to_return(status: 200, body: %({"name": "data-index"}), headers: {"Content-Type": "application/json"})
    end
  end
end
