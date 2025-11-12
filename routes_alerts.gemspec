Gem::Specification.new do |s|
  s.name        = "routes_alerts"
  s.version     = "1.0.7"
  s.summary     = "Create AWS alerts/metrics for routes"
  s.description = "Allows you to create metrics (for reporting, dashboards) and alerts for request time, count and response code based on your routes."
  s.authors     = [""]
  s.email       = "jarrett.baugh@gmail.com"
  s.files       = Dir.glob(['lib/**/*.rb'])
  s.homepage    = "https://github.com/jbaugh/routes_alerts"
  s.add_dependency "aws-sdk-cloudwatchlogs", "~>1.32"
  s.add_dependency "aws-sdk-cloudwatch", "~>1.32"
  s.required_ruby_version = '>= 2.6.0'
  s.license     = "MIT"
end
