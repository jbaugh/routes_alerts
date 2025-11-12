
class RoutesAlerts::RouteInfo
  attr_reader :path, :method, :max_duration, :min_count, :success_rate, 
              :alarm_period, :number_of_datapoints, :metrics, :namespace, 
              :log_group_name, :actions, :prefix

  def initialize(path:, method:, max_duration:, min_count:, success_rate:, alarm_period:, number_of_datapoints:, metrics:, namespace:, log_group_name:, actions:, prefix: "")
    @path = path.to_s
    @method = method.to_s.upcase
    @max_duration = max_duration.to_f
    @min_count = min_count.to_i
    @success_rate = success_rate.to_f
    @alarm_period = alarm_period.to_i
    @number_of_datapoints = number_of_datapoints.to_i
    @metrics = metrics
    @namespace = namespace.to_s
    @log_group_name = log_group_name.to_s
    @actions = actions || []
    @prefix = prefix.to_s
  end
end
