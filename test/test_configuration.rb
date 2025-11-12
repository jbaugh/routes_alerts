require_relative 'test_helper'

class TestConfiguration < Minitest::Test
  def setup
    super
    @config = RoutesAlerts::Configuration.new
  end

  def test_initialize_sets_default_values
    assert_equal RoutesAlerts::Configuration::DEFAULT_ALARM_PERIOD, @config.default_alarm_period
    assert_equal RoutesAlerts::Configuration::DEFAULT_NUMBER_OF_DATAPOINTS, @config.default_number_of_datapoints
    assert_equal RoutesAlerts::Configuration::DEFAULT_MAX_DURATION, @config.default_max_duration
    assert_equal RoutesAlerts::Configuration::DEFAULT_MIN_COUNT, @config.default_min_count
    assert_equal RoutesAlerts::Configuration::DEFAULT_SUCCESS_RATE, @config.default_success_rate
    assert_equal RoutesAlerts::Metrics::DEFAULT_METRICS, @config.default_metrics
    assert_equal [], @config.routes
    assert_equal [], @config.default_actions
    assert_instance_of Aws::CloudWatchLogs::Client, @config.cloudwatch_logs
  end

  def test_default_constants
    assert_equal 300, RoutesAlerts::Configuration::DEFAULT_ALARM_PERIOD
    assert_equal 2, RoutesAlerts::Configuration::DEFAULT_NUMBER_OF_DATAPOINTS
    assert_equal 100.0, RoutesAlerts::Configuration::DEFAULT_MAX_DURATION
    assert_equal 1, RoutesAlerts::Configuration::DEFAULT_MIN_COUNT
    assert_equal 99.0, RoutesAlerts::Configuration::DEFAULT_SUCCESS_RATE
  end

  def test_add_route_with_all_parameters
    @config.add_route(
      path: '/api/test',
      method: :get,
      max_duration: 250.5,
      min_count: 5,
      success_rate: 95.5,
      alarm_period: 600,
      number_of_datapoints: 3,
      metrics: ['Count'],
      namespace: 'MyNamespace',
      log_group_name: 'my-log-group',
      actions: ['arn:aws:sns:us-west-2:123456789012:my-topic']
    )

    assert_equal 1, @config.routes.length
    route = @config.routes.first
    
    assert_instance_of RoutesAlerts::RouteInfo, route
    # We can't directly test RouteInfo attributes since they're not exposed
    # This test mainly ensures the route is added without error
  end

  def test_add_route_with_minimal_parameters_uses_defaults
    @config.default_max_duration = 150.0
    @config.default_min_count = 3
    @config.default_success_rate = 98.0
    @config.default_alarm_period = 400
    @config.default_number_of_datapoints = 4
    @config.default_metrics = ['Duration']
    @config.default_namespace = 'DefaultNamespace'
    @config.default_log_group_name = 'default-log-group'
    @config.default_actions = ['default-action']

    @config.add_route(
      path: '/minimal',
      method: :post,
      max_duration: nil,
      min_count: nil,
      success_rate: nil,
      alarm_period: nil,
      number_of_datapoints: nil,
      metrics: nil,
      namespace: nil,
      log_group_name: nil,
      actions: nil
    )

    assert_equal 1, @config.routes.length
    # Route creation should succeed with default values
  end

  def test_add_route_converts_types_properly
    # Mock RouteInfo.new to verify the parameters being passed
    expected_params = {
      path: '/test/123',
      method: 'POST',
      max_duration: 123.5,
      min_count: 2,
      success_rate: 97.5,
      alarm_period: 500,
      number_of_datapoints: 3,
      log_group_name: 'test-log',
      namespace: 'TestSpace',
      actions: ['action1'],
      metrics: ['Count', 'Duration'],
      prefix: ""
    }

    route_info_mock = mock('route_info')
    RoutesAlerts::RouteInfo.expects(:new).with(**expected_params).returns(route_info_mock)

    @config.add_route(
      path: '/test/123',
      method: 'post',  # Should be converted to uppercase
      max_duration: '123.5',  # Should be converted to float
      min_count: '2',  # Should be converted to integer
      success_rate: '97.5',  # Should be converted to float
      alarm_period: '500',  # Should be converted to integer
      number_of_datapoints: '3',  # Should be converted to integer
      metrics: ['Count', 'Duration'],
      namespace: 'TestSpace',
      log_group_name: 'test-log',
      actions: ['action1'],
    )

    assert_equal 1, @config.routes.length
    assert_equal route_info_mock, @config.routes.first
  end

  def test_add_multiple_routes
    @config.add_route(
      path: '/route1',
      method: :get,
      max_duration: nil,
      min_count: nil,
      success_rate: nil,
      alarm_period: nil,
      number_of_datapoints: nil,
      metrics: nil,
      namespace: 'NS1',
      log_group_name: 'log1',
      actions: nil
    )

    @config.add_route(
      path: '/route2',
      method: :post,
      max_duration: nil,
      min_count: nil,
      success_rate: nil,
      alarm_period: nil,
      number_of_datapoints: nil,
      metrics: nil,
      namespace: 'NS2',
      log_group_name: 'log2',
      actions: nil
    )

    assert_equal 2, @config.routes.length
  end

  def test_attr_accessors_work
    @config.default_alarm_period = 999
    @config.default_number_of_datapoints = 5
    @config.default_max_duration = 500.0
    @config.default_min_count = 10
    @config.default_success_rate = 85.0
    @config.default_metrics = ['CustomMetric']
    @config.default_log_group_name = 'custom-log'
    @config.default_namespace = 'CustomNamespace'
    @config.default_actions = ['custom-action']

    assert_equal 999, @config.default_alarm_period
    assert_equal 5, @config.default_number_of_datapoints
    assert_equal 500.0, @config.default_max_duration
    assert_equal 10, @config.default_min_count
    assert_equal 85.0, @config.default_success_rate
    assert_equal ['CustomMetric'], @config.default_metrics
    assert_equal 'custom-log', @config.default_log_group_name
    assert_equal 'CustomNamespace', @config.default_namespace
    assert_equal ['custom-action'], @config.default_actions
  end
end