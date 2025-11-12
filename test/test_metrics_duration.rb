require_relative 'test_helper'

class TestMetricsDuration < Minitest::Test
  def setup
    super
    @config = RoutesAlerts::Configuration.new
    @route_info = RoutesAlerts::RouteInfo.new(
      path: '/api/users/{id}',
      method: 'GET',
      max_duration: 150.5,
      min_count: 1,
      success_rate: 99.0,
      alarm_period: 600,
      number_of_datapoints: 3,
      metrics: ['Duration'],
      namespace: 'TestNamespace',
      log_group_name: 'test-log-group',
      actions: ['arn:aws:sns:us-west-2:123456789012:test-topic']
    )
    @duration_metric = RoutesAlerts::Duration.new(@config, @route_info)
  end

  def test_filter_pattern
    expected = "{ $.path = \"/api/users/{id}\" && $.method = \"GET\" && EXISTS($.duration) }"
    assert_equal expected, @duration_metric.filter_pattern
  end

  def test_filter_pattern_handles_different_paths_and_methods
    route_info = RoutesAlerts::RouteInfo.new(
      path: '/api/v2/posts/{post_id}',
      method: 'PUT',
      max_duration: 100.0,
      min_count: 1,
      success_rate: 99.0,
      alarm_period: 300,
      number_of_datapoints: 2,
      metrics: ['Duration'],
      namespace: 'Test',
      log_group_name: 'test-log',
      actions: []
    )
    duration_metric = RoutesAlerts::Duration.new(@config, route_info)
    
    expected = "{ $.path = \"/api/v2/posts/{post_id}\" && $.method = \"PUT\" && EXISTS($.duration) }"
    assert_equal expected, duration_metric.filter_pattern
  end

  def test_metric_params
    expected = {
      log_group_name: 'test-log-group',
      filter_name: 'Duration-GET-_api_users_id',
      filter_pattern: "{ $.path = \"/api/users/{id}\" && $.method = \"GET\" && EXISTS($.duration) }",
      metric_transformations: [
        {
          metric_name: 'Duration-GET-_api_users_id',
          metric_namespace: 'TestNamespace',
          metric_value: '$.duration',
          default_value: 0,
          unit: 'Milliseconds',
        },
      ]
    }

    assert_equal expected, @duration_metric.metric_params
  end

  def test_alarm_params
    expected = {
      alarm_name: 'Alarm-Duration-GET-_api_users_id',
      actions_enabled: true,
      ok_actions: ['arn:aws:sns:us-west-2:123456789012:test-topic'],
      alarm_actions: ['arn:aws:sns:us-west-2:123456789012:test-topic'],
      metric_name: 'Duration-GET-_api_users_id',
      namespace: 'TestNamespace',
      statistic: 'Average',
      dimensions: [],
      period: 600,
      unit: 'Milliseconds',
      evaluation_periods: 3,
      datapoints_to_alarm: 3,
      threshold: 150.5,
      comparison_operator: 'GreaterThanThreshold',
      treat_missing_data: 'notBreaching',
    }

    assert_equal expected, @duration_metric.alarm_params
  end

  def test_alarm_params_with_no_actions
    route_info = RoutesAlerts::RouteInfo.new(
      path: '/test',
      method: 'GET',
      max_duration: 200.0,
      min_count: 1,
      success_rate: 99.0,
      alarm_period: 300,
      number_of_datapoints: 2,
      metrics: ['Duration'],
      namespace: 'Test',
      log_group_name: 'test-log',
      actions: []
    )
    duration_metric = RoutesAlerts::Duration.new(@config, route_info)

    params = duration_metric.alarm_params
    assert_equal false, params[:actions_enabled]
    assert_nil params[:ok_actions]
    assert_nil params[:alarm_actions]
    assert_equal 200.0, params[:threshold]
  end

  def test_create_calls_cloudwatch_methods
    @config.cloudwatch_logs.expects(:put_metric_filter).with(@duration_metric.metric_params).once
    @config.cloudwatch.expects(:put_metric_alarm).with(@duration_metric.alarm_params).once
    
    @duration_metric.create!
  end

  def test_inherits_from_base
    assert_kind_of RoutesAlerts::Base, @duration_metric
  end

  def test_uses_average_statistic
    params = @duration_metric.alarm_params
    assert_equal 'Average', params[:statistic]
  end

  def test_uses_greater_than_threshold_comparison
    params = @duration_metric.alarm_params
    assert_equal 'GreaterThanThreshold', params[:comparison_operator]
  end

  def test_metric_value_uses_json_path
    params = @duration_metric.metric_params
    transformation = params[:metric_transformations].first
    assert_equal '$.duration', transformation[:metric_value]
  end
end