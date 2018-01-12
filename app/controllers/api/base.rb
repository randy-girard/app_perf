# lib/api/base.rb
require 'roda'
require 'json'

module API
  class Base < Roda
    route do |r|
      r.on "listener" do
        r.run API::Listener
      end

      r.on "v1" do
        r.run API::V1::Stats
      end
    end
  end
end
