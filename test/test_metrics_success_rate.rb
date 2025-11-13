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
      metrics: [
        {
          id: "m1",
          metric_stat: {
            metric: {
              namespace: 'TestNamespace',
              metric_name: 'SuccessRate-GET-_api_users_id',
              dimensions: []
            },
            period: 600,
            stat: "Sum",
          },
          return_data: false
        },
        {
          id: "m2", 
          metric_stat: {
            metric: {
              namespace: 'TestNamespace',
              metric_name: 'Count-GET-_api_users_id',
              dimensions: [],
            },
            period: 600,
            stat: "Sum",
          },
          return_data: false
        },
        {
          id: "e1",
          expression: "(m1/m2)*100",
        }
      ],
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

  def test_uses_sum_statistic_for_ratio_calculation
    params = @success_rate_metric.alarm_params
    success_metric = params[:metrics].find { |m| m[:id] == "m1" }
    total_metric = params[:metrics].find { |m| m[:id] == "m2" }
    
    assert_equal 'Sum', success_metric[:metric_stat][:stat]
    assert_equal 'Sum', total_metric[:metric_stat][:stat]
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

  def test_uses_count_unit_for_metric
    metric_params = @success_rate_metric.metric_params
    transformation = metric_params[:metric_transformations].first
    assert_equal 'Count', transformation[:unit]
  end

  def test_filter_pattern_includes_success_status_codes
    pattern = @success_rate_metric.filter_pattern
    assert_includes pattern, '$.status >= 200'
    assert_includes pattern, '$.status < 300'
  end

  def test_alarm_uses_math_expression_for_success_rate_ratio
    params = @success_rate_metric.alarm_params
    
    # Check that we have the expected metrics
    success_metric = params[:metrics].find { |m| m[:id] == "m1" }
    total_metric = params[:metrics].find { |m| m[:id] == "m2" }
    expression_metric = params[:metrics].find { |m| m[:id] == "e1" }

    assert success_metric != nil
    assert total_metric != nil
    assert expression_metric != nil
    
    # Verify the math expression calculates percentage
    assert_equal "(m1/m2)*100", expression_metric[:expression]
    
    # Verify metric names
    assert_equal 'SuccessRate-GET-_api_users_id', success_metric[:metric_stat][:metric][:metric_name]
    assert_equal 'Count-GET-_api_users_id', total_metric[:metric_stat][:metric][:metric_name]
  end
end