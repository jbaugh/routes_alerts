require "config"

class RoutesAlerts
  def self.config
    self.configuration = ||= Config.new
    yield(configuration)
  end

end

