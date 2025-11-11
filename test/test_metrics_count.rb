require_relative 'test_helper'

class TestMetricsCount < Minitest::Test
  def setup
    super
    @config = RoutesAlerts::Configuration.new
    @route_info = RoutesAlerts::RouteInfo.new(
      path: '/api/users/{id}',
      method: 'GET',
      max_duration: 100.0,
      min_count: 5,
      success_rate: 99.0,
      alarm_period: 300,
      number_of_datapoints: 2,
      metrics: ['Count'],
      namespace: 'TestNamespace',
      log_group_name: 'test-log-group',
      actions: ['arn:aws:sns:us-west-2:123456789012:test-topic']
    )
    @count_metric = RoutesAlerts::Count.new(@config, @route_info)
  end

  def test_filter_pattern
    expected = "{ $.path = \"/api/users/{id}\" && $.method = \"GET\" }"
    assert_equal expected, @count_metric.filter_pattern
  end

  def test_filter_pattern_handles_different_methods
    route_info = RoutesAlerts::RouteInfo.new(
      path: '/api/posts',
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
    count_metric = RoutesAlerts::Count.new(@config, route_info)
    
    expected = "{ $.path = \"/api/posts\" && $.method = \"POST\" }"
    assert_equal expected, count_metric.filter_pattern
  end

  def test_metric_params
    expected = {
      log_group_name: 'test-log-group',
      filter_name: 'Count-GET-_api_users_id',
      filter_pattern: "{ $.path = \"/api/users/{id}\" && $.method = \"GET\" }",
      metric_transformations: [
        {
          metric_name: 'Count-GET-_api_users_id',
          metric_namespace: 'TestNamespace',
          metric_value: '1',
          default_value: 0,
          unit: 'Count',
        },
      ]
    }

    assert_equal expected, @count_metric.metric_params
  end

  def test_alarm_params
    expected = {
      alarm_name: 'Alarm-Count-GET-_api_users_id',
      actions_enabled: true,
      ok_actions: ['arn:aws:sns:us-west-2:123456789012:test-topic'],
      alarm_actions: ['arn:aws:sns:us-west-2:123456789012:test-topic'],
      metric_name: 'Count-GET-_api_users_id',
      namespace: 'TestNamespace',
      statistic: 'Sum',
      dimensions: [],
      period: 300,
      unit: 'Count',
      evaluation_periods: 2,
      datapoints_to_alarm: 2,
      threshold: 5,
      comparison_operator: 'LessThanOrEqualToThreshold',
      treat_missing_data: 'notBreaching',
    }

    assert_equal expected, @count_metric.alarm_params
  end

  def test_alarm_params_with_no_actions
    route_info = RoutesAlerts::RouteInfo.new(
      path: '/test',
      method: 'GET',
      max_duration: 100.0,
      min_count: 3,
      success_rate: 99.0,
      alarm_period: 600,
      number_of_datapoints: 4,
      metrics: ['Count'],
      namespace: 'Test',
      log_group_name: 'test-log',
      actions: []
    )
    count_metric = RoutesAlerts::Count.new(@config, route_info)

    params = count_metric.alarm_params
    assert_equal false, params[:actions_enabled]
    assert_nil params[:ok_actions]
    assert_nil params[:alarm_actions]
  end

  def test_create_calls_cloudwatch_methods
    @config.cloudwatch_logs.expects(:put_metric_filter).with(@count_metric.metric_params).once
    @config.cloudwatch_logs.expects(:put_metric_alarm).with(@count_metric.alarm_params).once
    
    @count_metric.create!
  end

  def test_inherits_from_base
    assert_kind_of RoutesAlerts::Base, @count_metric
  end
end