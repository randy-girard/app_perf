# lib/api/base.rb
require 'roda'
require 'json'

module API
  class Base < Roda
    plugin :multi_route

    route do |r|
      r.on "listener" do
        r.run API::Listener
      end

      r.on "v1" do
        r.on "metrics" do
          r.run API::V1::Metrics
        end

        r.on "stats" do
          r.run API::V1::Stats
        end
      end
    end
  end
end
