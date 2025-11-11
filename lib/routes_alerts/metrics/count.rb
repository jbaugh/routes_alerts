class RoutesAlerts::Metrics::Count
  attr_reader :route_info

  def initialize(route_info)
    @route_info = route_info
  end

  def params
    {
      log_group_name: log_group_name,
      filter_name: "Count-#{route_name}",
      filter_pattern: filter_pattern(route_name),
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

end
