require_relative 'test_helper'

class TestRouteInfo < Minitest::Test
  def test_initialize_with_all_parameters
    route = RoutesAlerts::RouteInfo.new(
      path: '/api/users/{id}',
      method: :get,
      max_duration: 250.5,
      min_count: 5,
      success_rate: 95.5,
      alarm_period: 600,
      number_of_datapoints: 3,
      metrics: ['Count', 'Duration'],
      namespace: 'MyNamespace',
      log_group_name: 'my-log-group',
      actions: ['arn:aws:sns:us-west-2:123456789012:my-topic']
    )

    assert_equal '/api/users/{id}', route.path
    assert_equal 'GET', route.method
    assert_equal 250.5, route.max_duration
    assert_equal 5, route.min_count
    assert_equal 95.5, route.success_rate
    assert_equal 600, route.alarm_period
    assert_equal 3, route.number_of_datapoints
    assert_equal ['Count', 'Duration'], route.metrics
    assert_equal 'MyNamespace', route.namespace
    assert_equal 'my-log-group', route.log_group_name
    assert_equal ['arn:aws:sns:us-west-2:123456789012:my-topic'], route.actions
  end

  def test_initialize_converts_path_to_string
    route = RoutesAlerts::RouteInfo.new(
      path: :symbol_path,
      method: :get,
      max_duration: 100.0,
      min_count: 1,
      success_rate: 99.0,
      alarm_period: 300,
      number_of_datapoints: 2,
      metrics: ['Count'],
      namespace: 'Test',
      log_group_name: 'test-log',
      actions: []
    )

    assert_equal 'symbol_path', route.path
    assert_instance_of String, route.path
  end

  def test_initialize_converts_method_to_uppercase_string
    %w[get post put delete patch].each do |method|
      route = RoutesAlerts::RouteInfo.new(
        path: '/test',
        method: method,
        max_duration: 100.0,
        min_count: 1,
        success_rate: 99.0,
        alarm_period: 300,
        number_of_datapoints: 2,
        metrics: ['Count'],
        namespace: 'Test',
        log_group_name: 'test-log',
        actions: []
      )

      assert_equal method.upcase, route.method
      assert_instance_of String, route.method
    end
  end

  def test_initialize_converts_symbol_method_to_uppercase_string
    route = RoutesAlerts::RouteInfo.new(
      path: '/test',
      method: :post,
      max_duration: 100.0,
      min_count: 1,
      success_rate: 99.0,
      alarm_period: 300,
      number_of_datapoints: 2,
      metrics: ['Count'],
      namespace: 'Test',
      log_group_name: 'test-log',
      actions: []
    )

    assert_equal 'POST', route.method
    assert_instance_of String, route.method
  end

  def test_initialize_converts_numeric_strings_to_proper_types
    route = RoutesAlerts::RouteInfo.new(
      path: '/test',
      method: 'get',
      max_duration: '150.75',
      min_count: '10',
      success_rate: '98.5',
      alarm_period: '450',
      number_of_datapoints: '5',
      metrics: ['Count'],
      namespace: 'Test',
      log_group_name: 'test-log',
      actions: []
    )

    assert_equal 150.75, route.max_duration
    assert_instance_of Float, route.max_duration
    
    assert_equal 10, route.min_count
    assert_instance_of Integer, route.min_count
    
    assert_equal 98.5, route.success_rate
    assert_instance_of Float, route.success_rate
    
    assert_equal 450, route.alarm_period
    assert_instance_of Integer, route.alarm_period
    
    assert_equal 5, route.number_of_datapoints
    assert_instance_of Integer, route.number_of_datapoints
  end

  def test_initialize_converts_namespace_and_log_group_name_to_string
    route = RoutesAlerts::RouteInfo.new(
      path: '/test',
      method: 'get',
      max_duration: 100.0,
      min_count: 1,
      success_rate: 99.0,
      alarm_period: 300,
      number_of_datapoints: 2,
      metrics: ['Count'],
      namespace: :symbol_namespace,
      log_group_name: :symbol_log_group,
      actions: []
    )

    assert_equal 'symbol_namespace', route.namespace
    assert_instance_of String, route.namespace
    
    assert_equal 'symbol_log_group', route.log_group_name
    assert_instance_of String, route.log_group_name
  end

  def test_initialize_handles_nil_actions
    route = RoutesAlerts::RouteInfo.new(
      path: '/test',
      method: 'get',
      max_duration: 100.0,
      min_count: 1,
      success_rate: 99.0,
      alarm_period: 300,
      number_of_datapoints: 2,
      metrics: ['Count'],
      namespace: 'Test',
      log_group_name: 'test-log',
      actions: nil
    )

    assert_equal [], route.actions
    assert_instance_of Array, route.actions
  end

  def test_initialize_preserves_array_actions
    actions = ['action1', 'action2']
    route = RoutesAlerts::RouteInfo.new(
      path: '/test',
      method: 'get',
      max_duration: 100.0,
      min_count: 1,
      success_rate: 99.0,
      alarm_period: 300,
      number_of_datapoints: 2,
      metrics: ['Count'],
      namespace: 'Test',
      log_group_name: 'test-log',
      actions: actions
    )

    assert_equal actions, route.actions
    assert_same actions, route.actions
  end

  def test_initialize_preserves_metrics_array
    metrics = ['Count', 'Duration', 'SuccessRate']
    route = RoutesAlerts::RouteInfo.new(
      path: '/test',
      method: 'get',
      max_duration: 100.0,
      min_count: 1,
      success_rate: 99.0,
      alarm_period: 300,
      number_of_datapoints: 2,
      metrics: metrics,
      namespace: 'Test',
      log_group_name: 'test-log',
      actions: []
    )

    assert_equal metrics, route.metrics
    assert_same metrics, route.metrics
  end

  def test_all_attributes_are_readable
    route = RoutesAlerts::RouteInfo.new(
      path: '/api/test',
      method: 'POST',
      max_duration: 200.0,
      min_count: 3,
      success_rate: 97.0,
      alarm_period: 500,
      number_of_datapoints: 4,
      metrics: ['Count', 'Duration'],
      namespace: 'TestNamespace',
      log_group_name: 'test-log-group',
      actions: ['test-action']
    )

    # Test that all attr_readers work
    assert_respond_to route, :path
    assert_respond_to route, :method
    assert_respond_to route, :max_duration
    assert_respond_to route, :min_count
    assert_respond_to route, :success_rate
    assert_respond_to route, :alarm_period
    assert_respond_to route, :number_of_datapoints
    assert_respond_to route, :metrics
    assert_respond_to route, :namespace
    assert_respond_to route, :log_group_name
    assert_respond_to route, :actions
  end
end