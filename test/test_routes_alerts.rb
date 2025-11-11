require_relative 'test_helper'

class TestRoutesAlerts < Minitest::Test
  def test_configuration_accessor
    assert_nil RoutesAlerts.configuration
    
    config = RoutesAlerts::Configuration.new
    RoutesAlerts.configuration = config
    
    assert_equal config, RoutesAlerts.configuration
  end

  def test_configure_block
    RoutesAlerts.configure do |config|
      config.default_alarm_period = 600
      config.default_max_duration = 200.0
    end
    
    assert_instance_of RoutesAlerts::Configuration, RoutesAlerts.configuration
    assert_equal 600, RoutesAlerts.configuration.default_alarm_period
    assert_equal 200.0, RoutesAlerts.configuration.default_max_duration
  end

  def test_configure_creates_configuration_if_nil
    assert_nil RoutesAlerts.configuration
    
    RoutesAlerts.configure { |config| }
    
    assert_instance_of RoutesAlerts::Configuration, RoutesAlerts.configuration
  end

  def test_configure_reuses_existing_configuration
    existing_config = RoutesAlerts::Configuration.new
    existing_config.default_alarm_period = 999
    RoutesAlerts.configuration = existing_config
    
    RoutesAlerts.configure do |config|
      config.default_max_duration = 300.0
    end
    
    assert_equal existing_config, RoutesAlerts.configuration
    assert_equal 999, RoutesAlerts.configuration.default_alarm_period
    assert_equal 300.0, RoutesAlerts.configuration.default_max_duration
  end

  def test_create_metrics_calls_metrics_for_each_route
    # Setup configuration with routes
    config = RoutesAlerts::Configuration.new
    config.add_route(
      path: '/api/users',
      method: :get,
      max_duration: nil,
      min_count: nil,
      success_rate: nil,
      alarm_period: nil,
      number_of_datapoints: nil,
      metrics: nil,
      namespace: 'TestNamespace',
      log_group_name: 'test-log-group',
      actions: nil
    )
    config.add_route(
      path: '/api/posts',
      method: :post,
      max_duration: nil,
      min_count: nil,
      success_rate: nil,
      alarm_period: nil,
      number_of_datapoints: nil,
      metrics: nil,
      namespace: 'TestNamespace',
      log_group_name: 'test-log-group',
      actions: nil
    )
    RoutesAlerts.configuration = config
    
    # Mock the Metrics class and its create_metrics! method
    metrics_mock = mock('metrics')
    metrics_mock.expects(:create_metrics!).with(config.routes[0]).once
    metrics_mock.expects(:create_metrics!).with(config.routes[1]).once
    
    RoutesAlerts::Metrics.expects(:new).with(config).returns(metrics_mock).twice
    
    RoutesAlerts.create_metrics!
  end

  def test_create_metrics_with_no_routes
    config = RoutesAlerts::Configuration.new
    RoutesAlerts.configuration = config
    
    # Should not call Metrics.new at all
    RoutesAlerts::Metrics.expects(:new).never
    
    RoutesAlerts.create_metrics!
  end
end