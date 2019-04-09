# frozen_string_literal: true

rails_root = Rails.root || File.dirname(__FILE__) + '/../..'

redis_config = YAML.safe_load(ERB.new(File.read(rails_root.to_s + '/config/redis.yml')).result)
redis_config.merge! redis_config.fetch(Rails.env, {})
redis_config.symbolize_keys!

redis_url = redis_config[:url] || "redis://#{redis_config[:host]}:#{redis_config[:port]}/0"

Sidekiq.configure_server do |config|
  config.redis = {
    url: redis_url,
    network_timeout: 5
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: redis_url,
    network_timeout: 5
  }
end
