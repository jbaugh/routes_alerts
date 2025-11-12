# Routes Alerts
Create metrics/alarms based on routing info.

[RubyGem page](https://rubygems.org/gems/routes_alerts)

```ruby
# Example usage:
RoutesAlerts.configure do |config|
  # Setup log group name / namespace (you can specify on a route itself)
  condig.prefix = "project"
  config.default_log_group_name = "something"
  config.default_namespace = "something-else"

  # Add actions if you want
  config.actions << "SomeSnsTopicARN"

  # Add a route with custom parameters
  config.add_route(path: "/api/v1/users", method: "GET", max_duration: 100, min_count: 1, success_rate: 99.0, alarm_period: 300, number_of_datapoints: 2, metrics: RoutesAlerts::Metrics::DEFAULT_METRICS)

  # Set default parameters
  config.default_max_duration = 150.0
  config.default_min_count = 5
  config.default_success_rate = 98.0
  config.default_alarm_period = 600
  config.default_number_of_datapoints = 3

  # Add another route using default parameters
  config.add_route(path: "/api/v1/orders", method: "POST")

  # Will use defaults, but only the Count metric
  config.add_route(path: "/api/v1/orders", method: "POST", metrics: [RoutesAlerts::Metrics::COUNT_METRIC_NAME])
end

# Run the alert setup
RoutesAlerts.create_metrics!
```

## Testing
`rake test`