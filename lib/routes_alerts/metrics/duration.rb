class RoutesAlerts::Metrics::Duration
  attr_reader :route_info, :config

  def initialize(route_info, config)
    @route_info = route_info
    @config = config
  end

  def create!
    # Implementation for creating duration metric
  end
end
