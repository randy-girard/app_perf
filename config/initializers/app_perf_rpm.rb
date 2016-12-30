require 'app_perf_rpm'

# AppPerfRpm.logger = Logger.new("app_perf_rpm.yml")
AppPerfRpm.configure do |rpm|
  rpm.license_key = ENV["APP_PERF_LICENSE_KEY"]
  rpm.application_name = "App Perf"
  rpm.sample_rate = 100
end
