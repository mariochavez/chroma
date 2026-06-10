# frozen_string_literal: true

require "test_helper"

class TenantTest < Minitest::Test
  include StubRequest

  def setup
    @default_config = Chroma.config.dup

    Chroma.connect_host = "http://chroma-server.org"

    initialize_stub_store
  end

  def teardown
    Chroma.instance_variable_set(:@config, @default_config)

    clear_stub_store
  end

  def test_it_creates_a_tenant
    tenant_name = "new_tenant"

    @stubs << stub_request(:post, "#{Chroma.api_url}/tenants").to_return(
      status: 200, body: "true", headers: {"Content-Type": "application/text"}
    )

    result = Chroma::Resources::Tenant.create(name: tenant_name)

    assert(result)
  end

  def test_it_retieves_a_tenant
    tenant_id = SecureRandom.uuid
    tenant_name = "new_tenant"

    @stubs << stub_request(:get, "#{Chroma.api_url}/tenants/#{tenant_name}").to_return(
      status: 200, body: %({"id": "#{tenant_id}", "name": "#{tenant_name}"}), headers: {"Content-Type": "application/text"}
    )

    tenant = Chroma::Resources::Tenant.get(tenant_name)

    assert_instance_of(Chroma::Resources::Tenant, tenant)
    assert_equal tenant_id, tenant.id
    assert_equal tenant_name, tenant.name
  end
end
