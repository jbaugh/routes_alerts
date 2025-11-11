require_relative "./base.rb"

class RoutesAlerts::SuccessRate < RoutesAlerts::Base
  def filter_pattern
    "{ $.path = \"#{route_info.path}\" && $.method = \"#{route_info.method}\" && $.status >= 200 && $.status < 300 }"
  end

  def metric_params
    {
      log_group_name: log_group_name,
      filter_name: "#{RoutesAlerts::Metrics::SUCCESS_METRIC_NAME}-#{route_name}",
      filter_pattern: filter_pattern,
      metric_transformations: [
        {
          metric_name: "#{RoutesAlerts::Metrics::SUCCESS_METRIC_NAME}-#{route_name}",
          metric_namespace: namespace,
          metric_value: "1",
          default_value: 0,
          unit: "Percent",
        },
      ]
    }
  end

  def alarm_params
    {
      alarm_name: "Alarm-#{RoutesAlerts::Metrics::SUCCESS_METRIC_NAME}-#{route_name}",
      actions_enabled: !!actions&.any?,
      ok_actions: actions,
      alarm_actions: actions,
      metric_name: "#{RoutesAlerts::Metrics::SUCCESS_METRIC_NAME}-#{route_name}",
      namespace: namespace,
      statistic: "Average",
      dimensions: [],
      period: route_info.alarm_period,
      unit: "Percent",
      evaluation_periods: route_info.number_of_datapoints,
      datapoints_to_alarm: route_info.number_of_datapoints,
      threshold: route_info.success_rate,
      comparison_operator: "LessThanThreshold",
      treat_missing_data: "breaching",
    }
  end
end
