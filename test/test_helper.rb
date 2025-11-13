require 'minitest/autorun'
require 'mocha/minitest'
require_relative '../lib/routes_alerts'

# Configure AWS SDK to use test credentials
ENV['AWS_ACCESS_KEY_ID'] = 'test_key'
ENV['AWS_SECRET_ACCESS_KEY'] = 'test_secret'
ENV['AWS_REGION'] = 'us-west-2'

class Minitest::Test
  def setup
    # Reset configuration between tests
    RoutesAlerts.configuration = nil
  end

  def teardown
    # Clean up any global state
    RoutesAlerts.configuration = nil
  end
end
