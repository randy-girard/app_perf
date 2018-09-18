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
      r.post String do |license_key|
        params = {
          "license_key" => license_key
        }

        return if license_key.nil?

        request.body.rewind

        compressed_body = Base64.decode64(request.body.read)
        data = Zlib::Inflate.inflate(compressed_body)
        json = MessagePack.unpack(data)

        hostname   = json.fetch("host") { nil }
        name       = json.fetch("name") { nil }
        spans      = json.fetch("spans") { [] }
        metrics    = json.fetch("metrics") { [] }
        tags       = json.fetch("tags") { [] }

        if tags.present?
          tags = process_tags(tags)
        end

        if metrics.present?
          MetricsWorker.perform_later(license_key, hostname, name, compress_data(metrics, tags))
        end

        if spans.present?
          SpansWorker.perform_later(license_key, hostname, name, compress_data(spans, tags))
        end

        status 200

        ""
      end
    end

    def compress_data(data, tags)
      packed_data = MessagePack.pack("data" => data, "tags" => tags)
      compressed_data = Zlib::Deflate.deflate(packed_data, Zlib::DEFAULT_COMPRESSION)
      Base64.encode64(compressed_data)
    end

    def process_tags(tags)
      hash = {}
      tags.each do |index, key, value|
        if key.to_s.length > 0 && value.to_s != "{}" && value.to_s.length > 0
          tag = Tag.where(key: key.to_s, value: value.to_s).first_or_create
          hash[index] = tag.id
        end
      end
      hash
    end
  end
end
