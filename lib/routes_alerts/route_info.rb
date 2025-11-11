class RouteAlerts::RouteInfo
  def initialize(path:, method: "GET", max_duration: 100.0, min_count: 1)
    @path = path.to_s
    @method = method.to_s.upcase
    @max_duration = max_duration.to_f
    @min_count = min_count.to_i
  end
end
