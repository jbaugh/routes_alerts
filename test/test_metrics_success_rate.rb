require_relative 'test_helper'

class TestMetricsSuccessRate < Minitest::Test
  def setup
    super
    @config = RoutesAlerts::Configuration.new
    @route_info = RoutesAlerts::RouteInfo.new(
      path: '/api/users/{id}',
      method: 'GET',
      max_duration: 100.0,
      min_count: 1,
      success_rate: 95.5,
      alarm_period: 600,
      number_of_datapoints: 3,
      metrics: ['SuccessRate'],
      namespace: 'TestNamespace',
      log_group_name: 'test-log-group',
      actions: ['arn:aws:sns:us-west-2:123456789012:test-topic']
    )
    @success_rate_metric = RoutesAlerts::SuccessRate.new(@config, @route_info)
  end

  def test_filter_pattern
    expected = "{ $.path = \"/api/users/{id}\" && $.method = \"GET\" && $.status >= 200 && $.status < 300 }"
    assert_equal expected, @success_rate_metric.filter_pattern
  end

  def test_filter_pattern_handles_different_paths_and_methods
    route_info = RoutesAlerts::RouteInfo.new(
      path: '/api/health',
      method: 'POST',
      max_duration: 100.0,
      min_count: 1,
      success_rate: 99.0,
      alarm_period: 300,
      number_of_datapoints: 2,
      metrics: ['SuccessRate'],
      namespace: 'Test',
      log_group_name: 'test-log',
      actions: []
    )
    success_rate_metric = RoutesAlerts::SuccessRate.new(@config, route_info)
    
    expected = "{ $.path = \"/api/health\" && $.method = \"POST\" && $.status >= 200 && $.status < 300 }"
    assert_equal expected, success_rate_metric.filter_pattern
  end

  def test_metric_params
    expected = {
      log_group_name: 'test-log-group',
      filter_name: 'SuccessRate-GET-_api_users_id',
      filter_pattern: "{ $.path = \"/api/users/{id}\" && $.method = \"GET\" && $.status >= 200 && $.status < 300 }",
      metric_transformations: [
        {
          metric_name: 'SuccessRate-GET-_api_users_id',
          metric_namespace: 'TestNamespace',
          metric_value: '1',
          default_value: 0,
          unit: 'Count',
        },
      ]
    }

    assert_equal expected, @success_rate_metric.metric_params
  end

  def test_alarm_params
    expected = {
      alarm_name: 'Alarm-SuccessRate-GET-_api_users_id',
      actions_enabled: true,
      ok_actions: ['arn:aws:sns:us-west-2:123456789012:test-topic'],
      alarm_actions: ['arn:aws:sns:us-west-2:123456789012:test-topic'],
      metric_name: 'SuccessRate-GET-_api_users_id',
      namespace: 'TestNamespace',
      statistic: 'Average',
      dimensions: [],
      period: 600,
      unit: 'Percent',
      evaluation_periods: 3,
      datapoints_to_alarm: 3,
      threshold: 95.5,
      comparison_operator: 'LessThanThreshold',
      treat_missing_data: 'breaching',
    }

    assert_equal expected, @success_rate_metric.alarm_params
  end

  def test_alarm_params_with_no_actions
    route_info = RoutesAlerts::RouteInfo.new(
      path: '/test',
      method: 'GET',
      max_duration: 100.0,
      min_count: 1,
      success_rate: 98.0,
      alarm_period: 300,
      number_of_datapoints: 2,
      metrics: ['SuccessRate'],
      namespace: 'Test',
      log_group_name: 'test-log',
      actions: []
    )
    success_rate_metric = RoutesAlerts::SuccessRate.new(@config, route_info)

    params = success_rate_metric.alarm_params
    assert_equal false, params[:actions_enabled]
    assert_nil params[:ok_actions]
    assert_nil params[:alarm_actions]
    assert_equal 98.0, params[:threshold]
  end

  def test_create_calls_cloudwatch_methods
    @config.cloudwatch_logs.expects(:put_metric_filter).with(@success_rate_metric.metric_params).once
    @config.cloudwatch.expects(:put_metric_alarm).with(@success_rate_metric.alarm_params).once
    
    @success_rate_metric.create!
  end

  def test_inherits_from_base
    assert_kind_of RoutesAlerts::Base, @success_rate_metric
  end

  def test_uses_average_statistic
    params = @success_rate_metric.alarm_params
    assert_equal 'Average', params[:statistic]
  end

  def test_uses_less_than_threshold_comparison
    params = @success_rate_metric.alarm_params
    assert_equal 'LessThanThreshold', params[:comparison_operator]
  end

  def test_treats_missing_data_as_breaching
    params = @success_rate_metric.alarm_params
    assert_equal 'breaching', params[:treat_missing_data]
  end

  def test_metric_value_is_constant_one
    params = @success_rate_metric.metric_params
    transformation = params[:metric_transformations].first
    assert_equal '1', transformation[:metric_value]
  end

  def test_uses_count_unit
    metric_params = @success_rate_metric.metric_params
    alarm_params = @success_rate_metric.alarm_params
    
    transformation = metric_params[:metric_transformations].first
    assert_equal 'Count', transformation[:unit]
    assert_equal 'Percent', alarm_params[:unit]
  end

  def test_filter_pattern_includes_success_status_codes
    pattern = @success_rate_metric.filter_pattern
    assert_includes pattern, '$.status >= 200'
    assert_includes pattern, '$.status < 300'
  end
end