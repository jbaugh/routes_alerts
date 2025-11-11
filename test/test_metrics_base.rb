require_relative 'test_helper'

class TestMetricsBase < Minitest::Test
  def setup
    super
    @config = RoutesAlerts::Configuration.new
    @route_info = RoutesAlerts::RouteInfo.new(
      path: '/api/users/{id}',
      method: 'GET',
      max_duration: 100.0,
      min_count: 1,
      success_rate: 99.0,
      alarm_period: 300,
      number_of_datapoints: 2,
      metrics: ['Count'],
      namespace: 'TestNamespace',
      log_group_name: 'test-log-group',
      actions: ['arn:aws:sns:us-west-2:123456789012:test-topic']
    )
    @base = RoutesAlerts::Base.new(@config, @route_info)
  end

  def test_initialize
    assert_equal @config, @base.config
    assert_equal @route_info, @base.route_info
  end

  def test_log_group_name
    assert_equal 'test-log-group', @base.log_group_name
  end

  def test_namespace
    assert_equal 'TestNamespace', @base.namespace
  end

  def test_route_name_formats_correctly
    assert_equal 'GET-_api_users_id', @base.route_name
  end

  def test_route_name_handles_special_characters
    route_info = RoutesAlerts::RouteInfo.new(
      path: '/api/v1/users/{user_id}/posts/{post_id}',
      method: 'POST',
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
    base = RoutesAlerts::Base.new(@config, route_info)
    
    assert_equal 'POST-_api_v1_users_user_id_posts_post_id', base.route_name
  end

  def test_route_name_handles_root_path
    route_info = RoutesAlerts::RouteInfo.new(
      path: '/',
      method: 'GET',
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
    base = RoutesAlerts::Base.new(@config, route_info)
    
    assert_equal 'GET-_', base.route_name
  end

  def test_actions_returns_array_when_actions_exist
    assert_equal ['arn:aws:sns:us-west-2:123456789012:test-topic'], @base.actions
  end

  def test_actions_returns_nil_when_no_actions
    route_info = RoutesAlerts::RouteInfo.new(
      path: '/test',
      method: 'GET',
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
    base = RoutesAlerts::Base.new(@config, route_info)
    
    assert_nil base.actions
  end

  def test_metric_params_raises_not_implemented_error
    error = assert_raises(NotImplementedError) do
      @base.metric_params
    end
    assert_equal "Subclasses must implement the metric_params method", error.message
  end

  def test_alarm_params_raises_not_implemented_error
    error = assert_raises(NotImplementedError) do
      @base.alarm_params
    end
    assert_equal "Subclasses must implement the alarm_params method", error.message
  end

  def test_create_calls_cloudwatch_methods
    metric_params = { test: 'metric_params' }
    alarm_params = { test: 'alarm_params' }
    
    @base.stubs(:metric_params).returns(metric_params)
    @base.stubs(:alarm_params).returns(alarm_params)
    
    @config.cloudwatch_logs.expects(:put_metric_filter).with(metric_params).once
    @config.cloudwatch_logs.expects(:put_metric_alarm).with(alarm_params).once
    
    @base.create!
  end
end