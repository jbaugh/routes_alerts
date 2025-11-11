require 'aws-sdk-cloudwatchlogs'
require_relative "./metrics.rb"
require_relative "./route_info.rb"

module RoutesAlerts
  class Configuration
    DEFAULT_ALARM_PERIOD = 300
    DEFAULT_NUMBER_OF_DATAPOINTS = 2
    DEFAULT_MAX_DURATION = 100.0
    DEFAULT_MIN_COUNT = 1
    DEFAULT_SUCCESS_RATE = 99.0

    attr_accessor :routes,
                  :default_alarm_period,
                  :default_number_of_datapoints,
                  :default_max_duration,
                  :default_min_count,
                  :default_success_rate,
                  :default_metrics,
                  :default_log_group_name,
                  :default_namespace,
                  :cloudwatch_logs,
                  :default_actions

    def initialize
      @cloudwatch_logs = Aws::CloudWatchLogs::Client.new(region: "us-west-2")
      @default_alarm_period = DEFAULT_ALARM_PERIOD
      @default_number_of_datapoints = DEFAULT_NUMBER_OF_DATAPOINTS
      @default_max_duration = DEFAULT_MAX_DURATION
      @default_min_count = DEFAULT_MIN_COUNT
      @default_success_rate = DEFAULT_SUCCESS_RATE
      @default_metrics = RoutesAlerts::Metrics::DEFAULT_METRICS
      @routes = []
      @default_actions = []
    end

    def add_route(path:, method:, max_duration:, min_count:, success_rate:, alarm_period:, number_of_datapoints:, metrics:, namespace:, log_group_name:, actions:)
      route_info = RoutesAlerts::RouteInfo.new(
        path: path.to_s,
        method: method.to_s.upcase,
        max_duration: (max_duration || default_max_duration).to_f,
        min_count: (min_count || default_min_count).to_i,
        success_rate: (success_rate || default_success_rate).to_f,
        alarm_period: (alarm_period || default_alarm_period).to_i,
        number_of_datapoints: (number_of_datapoints || default_number_of_datapoints).to_i,
        log_group_name: (log_group_name || default_log_group_name),
        namespace: (namespace || default_namespace),
        actions: (actions || default_actions),
        metrics: (metrics || default_metrics)
      )
      self.routes << route_info
    end
  end
end
