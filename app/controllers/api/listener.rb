require 'base64'
require 'json'
require 'zlib'
require 'stringio'

module Api
  class Listener < Roda
    plugin :json
    plugin :all_verbs
    plugin :sinatra_helpers

    route do |r|
      r.post Integer, String do |protocol_version, license_key|
        params = {
          "protocol_version" => protocol_version,
          "license_key" => license_key
        }

        request.body.rewind

        AppPerfAgentWorker.perform_later(params, request.body.read)

        status 200

        ""
      end
    end
  end
end
