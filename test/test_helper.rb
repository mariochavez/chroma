# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
ENV["RUBY_NEXT_TRANSPILE_MODE"] = "rewrite"
ENV["RUBY_NEXT_EDGE"] = "1"
ENV["RUBY_NEXT_PROPOSED"] = "1"
require "ruby-next/language/runtime" unless ENV["CI"]

require "chroma-db"

require "minitest/autorun"
require "webmock/minitest"

require File.expand_path("support/stub_request", __dir__)

WebMock.disable_net_connect!
