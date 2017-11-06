require 'app_perf_rpm'

AppPerfRpm.configure do |rpm|
  rpm.application_name = "App Perf"
  rpm.license_key = ENV["APP_PERF_LICENSE_KEY"]
  rpm.ssl = ENV["APP_PERF_SSL"] == "true"
  rpm.sample_rate = ENV["APP_PERF_SAMPLE_RATE"]
  rpm.flush_interval = ENV["APP_PERF_FLUSH_INTERVAL"]
end
