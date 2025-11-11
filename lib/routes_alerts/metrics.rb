class RoutesAlerts::Metrics
  attr_reader :cloudwatch_logs

  def initialize
    @cloudwatch_logs = Aws::CloudWatchLogs::Client.new(region: "us-west-2")
  end
  
  def create_count_metric(route_info)
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
