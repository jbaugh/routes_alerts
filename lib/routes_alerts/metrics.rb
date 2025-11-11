require_relative "./metrics/base.rb"
require_relative "./metrics/count.rb"
require_relative "./metrics/duration.rb"
require_relative "./metrics/success_rate.rb"

class RoutesAlerts::Metrics
  COUNT_METRIC_NAME = "Count"
  DURATION_METRIC_NAME = "Duration"
  SUCCESS_METRIC_NAME = "SuccessRate"

  DEFAULT_METRICS = [
    COUNT_METRIC_NAME,
    DURATION_METRIC_NAME,
    SUCCESS_METRIC_NAME
  ]

  attr_reader :config

  def initialize(config)
    @config = config
  end

  def create_metrics!(route_info)
    route_info.metrics.each do |metric|
      case metric
      when COUNT_METRIC_NAME
        RoutesAlerts::Count.new(config, route_info).create!
      when DURATION_METRIC_NAME
        RoutesAlerts::Duration.new(config, route_info).create!
      when SUCCESS_METRIC_NAME
        RoutesAlerts::SuccessRate.new(config, route_info).create!
      else
        raise "Unknown metric type: #{metric}"
      end
    end
  end
end
