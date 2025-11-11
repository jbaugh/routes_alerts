require_relative 'test_helper'

class TestMetrics < Minitest::Test
  def setup
    super
    @config = RoutesAlerts::Configuration.new
    @route_info = RoutesAlerts::RouteInfo.new(
      path: '/api/test',
      method: 'GET',
      max_duration: 100.0,
      min_count: 1,
      success_rate: 99.0,
      alarm_period: 300,
      number_of_datapoints: 2,
      metrics: ['Count', 'Duration'],
      namespace: 'TestNamespace',
      log_group_name: 'test-log-group',
      actions: ['test-action']
    )
    @metrics = RoutesAlerts::Metrics.new(@config)
  end

  def test_constants
    assert_equal "Count", RoutesAlerts::Metrics::COUNT_METRIC_NAME
    assert_equal "Duration", RoutesAlerts::Metrics::DURATION_METRIC_NAME
    assert_equal "SuccessRate", RoutesAlerts::Metrics::SUCCESS_METRIC_NAME
    
    expected_default_metrics = ["Count", "Duration", "SuccessRate"]
    assert_equal expected_default_metrics, RoutesAlerts::Metrics::DEFAULT_METRICS
  end

  def test_initialize
    assert_equal @config, @metrics.config
  end

  def test_create_metrics_with_count_metric
    route_info_with_count = RoutesAlerts::RouteInfo.new(
      path: '/api/count',
      method: 'GET',
      max_duration: 100.0,
      min_count: 1,
      success_rate: 99.0,
      alarm_period: 300,
      number_of_datapoints: 2,
      metrics: ['Count'],
      namespace: 'TestNamespace',
      log_group_name: 'test-log-group',
      actions: []
    )

    count_metric_mock = mock('count_metric')
    count_metric_mock.expects(:create!).once

    RoutesAlerts::Count.expects(:new).with(@config, route_info_with_count).returns(count_metric_mock)

    @metrics.create_metrics!(route_info_with_count)
  end

  def test_create_metrics_with_duration_metric
    route_info_with_duration = RoutesAlerts::RouteInfo.new(
      path: '/api/duration',
      method: 'GET',
      max_duration: 100.0,
      min_count: 1,
      success_rate: 99.0,
      alarm_period: 300,
      number_of_datapoints: 2,
      metrics: ['Duration'],
      namespace: 'TestNamespace',
      log_group_name: 'test-log-group',
      actions: []
    )

    duration_metric_mock = mock('duration_metric')
    duration_metric_mock.expects(:create!).once

    RoutesAlerts::Duration.expects(:new).with(@config, route_info_with_duration).returns(duration_metric_mock)

    @metrics.create_metrics!(route_info_with_duration)
  end

  def test_create_metrics_with_success_rate_metric
    route_info_with_success = RoutesAlerts::RouteInfo.new(
      path: '/api/success',
      method: 'GET',
      max_duration: 100.0,
      min_count: 1,
      success_rate: 99.0,
      alarm_period: 300,
      number_of_datapoints: 2,
      metrics: ['SuccessRate'],
      namespace: 'TestNamespace',
      log_group_name: 'test-log-group',
      actions: []
    )

    success_metric_mock = mock('success_metric')
    success_metric_mock.expects(:create!).once

    RoutesAlerts::SuccessRate.expects(:new).with(@config, route_info_with_success).returns(success_metric_mock)

    @metrics.create_metrics!(route_info_with_success)
  end

  def test_create_metrics_with_multiple_metrics
    route_info_with_multiple = RoutesAlerts::RouteInfo.new(
      path: '/api/multiple',
      method: 'POST',
      max_duration: 100.0,
      min_count: 1,
      success_rate: 99.0,
      alarm_period: 300,
      number_of_datapoints: 2,
      metrics: ['Count', 'Duration', 'SuccessRate'],
      namespace: 'TestNamespace',
      log_group_name: 'test-log-group',
      actions: []
    )

    count_mock = mock('count_metric')
    duration_mock = mock('duration_metric')
    success_mock = mock('success_metric')

    count_mock.expects(:create!).once
    duration_mock.expects(:create!).once
    success_mock.expects(:create!).once

    RoutesAlerts::Count.expects(:new).with(@config, route_info_with_multiple).returns(count_mock)
    RoutesAlerts::Duration.expects(:new).with(@config, route_info_with_multiple).returns(duration_mock)
    RoutesAlerts::SuccessRate.expects(:new).with(@config, route_info_with_multiple).returns(success_mock)

    @metrics.create_metrics!(route_info_with_multiple)
  end

  def test_create_metrics_with_empty_metrics_array
    route_info_with_no_metrics = RoutesAlerts::RouteInfo.new(
      path: '/api/none',
      method: 'GET',
      max_duration: 100.0,
      min_count: 1,
      success_rate: 99.0,
      alarm_period: 300,
      number_of_datapoints: 2,
      metrics: [],
      namespace: 'TestNamespace',
      log_group_name: 'test-log-group',
      actions: []
    )

    # Should not create any metrics
    RoutesAlerts::Count.expects(:new).never
    RoutesAlerts::Duration.expects(:new).never
    RoutesAlerts::SuccessRate.expects(:new).never

    @metrics.create_metrics!(route_info_with_no_metrics)
  end

  def test_create_metrics_with_unknown_metric_raises_error
    route_info_with_unknown = RoutesAlerts::RouteInfo.new(
      path: '/api/unknown',
      method: 'GET',
      max_duration: 100.0,
      min_count: 1,
      success_rate: 99.0,
      alarm_period: 300,
      number_of_datapoints: 2,
      metrics: ['UnknownMetric'],
      namespace: 'TestNamespace',
      log_group_name: 'test-log-group',
      actions: []
    )

    error = assert_raises(RuntimeError) do
      @metrics.create_metrics!(route_info_with_unknown)
    end

    assert_equal "Unknown metric type: UnknownMetric", error.message
  end

  def test_create_metrics_with_mixed_known_and_unknown_metrics
    route_info_with_mixed = RoutesAlerts::RouteInfo.new(
      path: '/api/mixed',
      method: 'GET',
      max_duration: 100.0,
      min_count: 1,
      success_rate: 99.0,
      alarm_period: 300,
      number_of_datapoints: 2,
      metrics: ['Count', 'UnknownMetric'],
      namespace: 'TestNamespace',
      log_group_name: 'test-log-group',
      actions: []
    )

    count_mock = mock('count_metric')
    count_mock.expects(:create!).once

    RoutesAlerts::Count.expects(:new).with(@config, route_info_with_mixed).returns(count_mock)

    error = assert_raises(RuntimeError) do
      @metrics.create_metrics!(route_info_with_mixed)
    end

    assert_equal "Unknown metric type: UnknownMetric", error.message
  end
end