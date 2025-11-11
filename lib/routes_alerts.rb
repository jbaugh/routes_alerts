require_relative "./routes_alerts/configuration.rb"


module RoutesAlerts
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= RoutesAlerts::Configuration.new
    yield(configuration)
  end

  def self.create_metrics!
    configuration.routes.each do |route|
      RoutesAlerts::Metrics.new(configuration).create_metrics!(route)
    end
  end
end
