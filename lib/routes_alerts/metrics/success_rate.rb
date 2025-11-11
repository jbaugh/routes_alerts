class RoutesAlerts::Metrics::SuccessRate
  attr_reader :route_info, :config

  def initialize(route_info, config)
    @route_info = route_info
    @config = config
  end

  def create!
    # Implementation for creating success rate metric
  end
end
