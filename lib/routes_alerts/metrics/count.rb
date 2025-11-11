class RoutesAlerts::Metrics::Count < RoutesAlerts::Metrics::Base
  def filter_pattern
    "{ $.path = \"#{route_info.path}\" && $.method = \"#{route_info.method}\" }"
  end

  def metric_params
    {
      log_group_name: log_group_name,
      filter_name: "#{RoutesAlerts::Metrics::COUNT_METRIC_NAME}-#{route_name}",
      filter_pattern: filter_pattern,
      metric_transformations: [
        {
          metric_name: "Count-#{route_name}",
          metric_namespace: namespace,
          metric_value: "1",
          default_value: 0,
          unit: "Count",
        },
      ]
    }
  end

  def alarm_params
    {
      alarm_name: "Alarm-#{RoutesAlerts::Metrics::COUNT_METRIC_NAME}-#{route_name}",
      actions_enabled: actions.any?,
      ok_actions: actions,
      alarm_actions: actions,
      metric_name: "#{RoutesAlerts::Metrics::COUNT_METRIC_NAME}-#{route_name}",
      namespace: namespace,
      statistic: "Sum",
      dimensions: [],
      period: route_info.alarm_period,
      unit: "Count",
      evaluation_periods: route_info.number_of_datapoints,
      datapoints_to_alarm: route_info.number_of_datapoints,
      threshold: route_info.min_count,
      comparison_operator: "LessThanOrEqualToThreshold",
      treat_missing_data: "notBreaching",
    }
  end
end
