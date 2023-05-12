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

  def stub_successful_request(url)
    @stubs << stub_request(:any, url).to_return(status: 200, body: %({"name": "data-index"}), headers: {"Content-Type": "application/json"})
  end
end
