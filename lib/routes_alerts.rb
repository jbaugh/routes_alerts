require_relative "./configuration.rb"

class RoutesAlerts
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= RoutesAlerts::Configuration.new
    yield(configuration)
  end
end


