# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "chroma-db"

require "minitest/autorun"
require "webmock/minitest"

require File.expand_path("support/stub_request", __dir__)

WebMock.disable_net_connect!
