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
          unit: "Count",
        },
      ]
    }
  end

  def alarm_params
    {
      alarm_name: "#{prefix}Alarm-#{RoutesAlerts::Metrics::SUCCESS_METRIC_NAME}-#{route_name}",
      actions_enabled: !!actions&.any?,
      ok_actions: actions,
      alarm_actions: actions,
      metrics: [
        {
          id: "m1",
          metric_stat: {
            metric: {
              namespace: namespace,
              metric_name: "#{RoutesAlerts::Metrics::SUCCESS_METRIC_NAME}-#{route_name}",
              dimensions: [],
            },
            period: route_info.alarm_period,
            stat: "Sum",
          },
          return_data: false
        },
        {
          id: "m2", 
          metric_stat: {
            metric: {
              namespace: namespace,
              metric_name: "#{RoutesAlerts::Metrics::COUNT_METRIC_NAME}-#{route_name}",
              dimensions: [],
            },
            period: route_info.alarm_period,
            stat: "Sum",
          },
          return_data: false
        },
        {
          id: "e1",
          expression: "(m1/m2)*100",
        }
      ],
      evaluation_periods: route_info.number_of_datapoints,
      datapoints_to_alarm: route_info.number_of_datapoints,
      threshold: route_info.success_rate,
      comparison_operator: "LessThanThreshold",
      treat_missing_data: "notBreaching",
    }
  end
end
