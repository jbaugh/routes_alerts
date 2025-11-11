require_relative "./base.rb"

class RoutesAlerts::Duration < RoutesAlerts::Base
  def filter_pattern
    "{ $.path = \"#{route_info.path}\" && $.method = \"#{route_info.method}\" && EXISTS($.duration) }"
  end

  def metric_params
    {
      log_group_name: log_group_name,
      filter_name: "#{RoutesAlerts::Metrics::DURATION_METRIC_NAME}-#{route_name}",
      filter_pattern: filter_pattern,
      metric_transformations: [
        {
          metric_name: "Duration-#{route_name}",
          metric_namespace: namespace,
          metric_value: "$.duration",
          default_value: 0,
          unit: "Milliseconds",
        },
      ]
    }
  end

  def alarm_params
    {
      alarm_name: "Alarm-#{RoutesAlerts::Metrics::DURATION_METRIC_NAME}-#{route_name}",
      actions_enabled: !!actions&.any?,
      ok_actions: actions,
      alarm_actions: actions,
      metric_name: "#{RoutesAlerts::Metrics::DURATION_METRIC_NAME}-#{route_name}",
      namespace: namespace,
      statistic: "Average",
      dimensions: [],
      period: route_info.alarm_period,
      unit: "Milliseconds",
      evaluation_periods: route_info.number_of_datapoints,
      datapoints_to_alarm: route_info.number_of_datapoints,
      threshold: route_info.max_duration,
      comparison_operator: "GreaterThanThreshold",
      treat_missing_data: "notBreaching",
    }
  end
end
