class RoutesAlerts::Base
  attr_reader :route_info, :config

  def initialize(config, route_info)
    @config = config
    @route_info = route_info
  end

  def metric_params
    raise NotImplementedError, "Subclasses must implement the metric_params method"
  end

  def alarm_params
    raise NotImplementedError, "Subclasses must implement the alarm_params method"
  end

  def create!
    config.cloudwatch_logs.put_metric_filter(metric_params)
    config.cloudwatch_logs.put_metric_alarm(alarm_params)
  end

  def log_group_name
    route_info.log_group_name
  end

  def namespace
    route_info.namespace
  end

  def route_name
    "#{route_info.method}-#{route_info.path.gsub("/", "_").gsub("{", "").gsub("}", "")}"
  end

  def actions
    route_info.actions.any? ? route_info.actions : nil
  end

  def prefix
    if route_info.prefix.empty?
      ""
    else
      "#{route_info.prefix}-"
    end
  end
end
