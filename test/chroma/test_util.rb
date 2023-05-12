# frozen_string_literal: true

require "test_helper"

class UtilTest < Minitest::Test
  def setup
    @default_config = Chroma.config.dup

    @out = StringIO.new
    logger = ::Logger.new(@out)

    logger.formatter = proc { |_severity, _datetime, _progname, message|
      message
    }

    Chroma.logger = logger
    Chroma.log_level = Chroma::LEVEL_DEBUG
  end

  def teardown
    Chroma.instance_variable_set(:@config, @default_config)
  end

  def test_it_logs_error
    Chroma::Util.log_error("Error")
    assert_equal "message=Error", @out.string
  end

  def test_it_logs_debug
    Chroma::Util.log_debug("Debug")
    assert_equal "message=Debug", @out.string
  end

  def test_it_logs_info
    Chroma::Util.log_info("Info")
    assert_equal "message=Info", @out.string
  end
end
