require 'base64'
require 'json'
require 'zlib'
require 'stringio'

module API
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

        case params["protocol_version"].to_s
        when "2"
          AppPerfAgentWorker.perform_later(params, request.body.read)
        when "3"
          OpenTracingWorker.perform_later(params, request.body.read)
        end

        status 200

        ""
      end
    end
  end
end
