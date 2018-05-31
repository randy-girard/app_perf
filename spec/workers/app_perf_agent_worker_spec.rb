# -*- encoding: utf-8 -*-
require "rails_helper"

describe AppPerfAgentWorker do

  # TODO: auto-generated
  describe '#perform' do
    context "trace header is set" do

    end

    it "process trace" do
      user = User.create(:email => "user@example.com", :password => "password")

      params = {
        "license_key" => user.license_key,
        "protocol_version" => 2
      }

      body = MessagePack.pack({
        "name" => "App Name",
        "host" => "localhost",
        "data" => [
          ["rack", "76f5d5efca2b394d1020784362d7aeb5850c14f8",  1503513734.8342,  2620.48101425171, {}],
          ["rack-middleware", "76f5d5efca2b394d1020784362d7aeb5850c14f8", 1503513734.83423,   2620.4309463501, {}],
          ["rack-middleware", "76f5d5efca2b394d1020784362d7aeb5850c14f8", 1503513734.83451,  2620.15390396118, {}],
          ["rack-middleware", "76f5d5efca2b394d1020784362d7aeb5850c14f8", 1503513735.57966,  1874.99022483826, {}],
          ["rack-middleware", "76f5d5efca2b394d1020784362d7aeb5850c14f8", 1503513735.57973,  1874.91822242737, {}],
          ["rack-middleware", "76f5d5efca2b394d1020784362d7aeb5850c14f8", 1503513735.57975,  1874.87387657166, {}],
          ["rack-middleware", "76f5d5efca2b394d1020784362d7aeb5850c14f8", 1503513735.57976,  1874.85504150391, {}],
          ["rack-middleware", "76f5d5efca2b394d1020784362d7aeb5850c14f8",  1503513735.5798,  1874.80115890503, {}],
          ["rack-middleware", "76f5d5efca2b394d1020784362d7aeb5850c14f8", 1503513735.58015,  1874.42708015442, {}],
          ["rack-middleware", "76f5d5efca2b394d1020784362d7aeb5850c14f8", 1503513735.58018,  1874.40013885498, {}],
          ["rack-middleware", "76f5d5efca2b394d1020784362d7aeb5850c14f8", 1503513735.58042,  1874.14216995239, {}],
          ["rack-middleware", "76f5d5efca2b394d1020784362d7aeb5850c14f8", 1503513735.58045,  1874.11212921143, {}],
          ["rack-middleware", "76f5d5efca2b394d1020784362d7aeb5850c14f8", 1503513735.58047,  1874.08876419067, {}],
          ["rack-middleware", "76f5d5efca2b394d1020784362d7aeb5850c14f8", 1503513735.67874,  1775.81310272217, {}],
          ["rack-middleware", "76f5d5efca2b394d1020784362d7aeb5850c14f8", 1503513735.67878,  1775.76780319214, {}],
          ["rack-middleware", "76f5d5efca2b394d1020784362d7aeb5850c14f8", 1503513735.68001,  1774.53112602234, {}],
          ["rack-middleware", "76f5d5efca2b394d1020784362d7aeb5850c14f8", 1503513735.68003,  1774.50394630432, {}],
          ["rack-middleware", "76f5d5efca2b394d1020784362d7aeb5850c14f8", 1503513735.68005,  1774.46889877319, {}],
          ["rack-middleware", "76f5d5efca2b394d1020784362d7aeb5850c14f8", 1503513735.68006,  1774.37210083008, {}],
          ["rack-middleware", "76f5d5efca2b394d1020784362d7aeb5850c14f8", 1503513735.68009,  1773.93984794617, {}],
          ["rack-middleware", "76f5d5efca2b394d1020784362d7aeb5850c14f8",  1503513735.6801,  1773.88501167297, {}],
          ["rack-middleware", "76f5d5efca2b394d1020784362d7aeb5850c14f8", 1503513735.68012,  1773.86283874512, {}],
          ["rack-middleware", "76f5d5efca2b394d1020784362d7aeb5850c14f8", 1503513735.68012,   1773.8471031189, {}],
          ["rack-middleware", "76f5d5efca2b394d1020784362d7aeb5850c14f8", 1503513735.68013,  1773.80037307739, {}],
          ["rack-middleware", "76f5d5efca2b394d1020784362d7aeb5850c14f8", 1503513735.68014,  1773.71287345886, {}],
          ["rack-middleware", "76f5d5efca2b394d1020784362d7aeb5850c14f8", 1503513735.68018,  1773.66900444031, {}],
          ["rack-middleware", "76f5d5efca2b394d1020784362d7aeb5850c14f8", 1503513735.68023,  1773.60510826111, {}],
          ["actioncontroller", "76f5d5efca2b394d1020784362d7aeb5850c14f8", 1503513735.76495,   1688.8210773468, {}],
          ["activerecord", "76f5d5efca2b394d1020784362d7aeb5850c14f8", 1503513737.44051, 0.527143478393555, {}],
          ["activerecord", "76f5d5efca2b394d1020784362d7aeb5850c14f8",  1503513737.1012,  322.949171066284, {}],
          ["activerecord", "76f5d5efca2b394d1020784362d7aeb5850c14f8", 1503513736.80884,  284.103155136108, {}],
          ["activerecord", "76f5d5efca2b394d1020784362d7aeb5850c14f8", 1503513736.49513,  304.527044296265, {}],
          ["activerecord", "76f5d5efca2b394d1020784362d7aeb5850c14f8", 1503513736.18195,  304.128885269165, {}],
          ["activerecord", "76f5d5efca2b394d1020784362d7aeb5850c14f8", 1503513735.86414,  309.940099716187, {}],
          ["activerecord", "76f5d5efca2b394d1020784362d7aeb5850c14f8", 1503513735.84278, 0.322103500366211, {}],
          ["activerecord", "76f5d5efca2b394d1020784362d7aeb5850c14f8", 1503513735.82243, 0.725984573364258, {}],
          ["activerecord", "76f5d5efca2b394d1020784362d7aeb5850c14f8", 1503513735.77869, 0.482797622680664, {}]
        ]
      })
      compressed_body = Zlib::Deflate.deflate(body, Zlib::DEFAULT_COMPRESSION)
      encoded_body = Base64.encode64(compressed_body)

      app_perf_agent_worker = AppPerfAgentWorker.new
      expect { app_perf_agent_worker.perform(params, encoded_body) }
        .to change {Application.count}.by(1)
        .and change{DatabaseType.count}.by(0)
        .and change{Trace.count}.by(1)
        .and change{Span.count}.by(37)
      expect(Span.where("exclusive_duration < 0").count).to eql(0)
    end

    it 'works' do
      user = User.create(:email => "user@example.com", :password => "password")

      params = {
        "license_key" => user.license_key,
        "protocol_version" => 2
      }

      body = MessagePack.pack({
        "name" => "App Name",
        "host" => "localhost",
        "data" => [
          ["activerecord", "a0b1d8d48f4565e10484b452aee413400980768e", 1483021545.2476869, 0.8051395416259766, {"adapter" => "postgresql"}],
          ["activerecord", "a0b1d8d48f4565e10484b452aee413400980768e", 1483021545.25277, 0.5490779876708984, {"adapter" => "postgresql"}],
          ["activerecord", "a0b1d8d48f4565e10484b452aee413400980768e", 1483021545.26422, 2.6819705963134766, {"adapter" => "postgresql"}],
          ["actioncontroller", "a0b1d8d48f4565e10484b452aee413400980768e", 1483021545.2456489, 116.8220043182373, {"controller" => "TestController"}],
          ["rack", "a0b1d8d48f4565e10484b452aee413400980768e", 1483021545.220119, 143.70012283325195, {}],

          ["activerecord", "b0b1d8d48f4565e10484b452aee413400980768e", 1483021545.2476869, 0.8051395416259766, {"adapter" => "postgresql"}],
          ["activerecord", "b0b1d8d48f4565e10484b452aee413400980768e", 1483021545.25277, 0.5490779876708984, {"adapter" => "postgresql"}],
          ["activerecord", "b0b1d8d48f4565e10484b452aee413400980768e", 1483021545.26422, 2.6819705963134766, {"adapter" => "postgresql"}],
          ["actioncontroller", "b0b1d8d48f4565e10484b452aee413400980768e", 1483021545.2456489, 116.8220043182373, {}],
          ["rack", "b0b1d8d48f4565e10484b452aee413400980768e", 1483021545.220119, 143.70012283325195, {}],
        ]
      })

      compressed_body = Zlib::Deflate.deflate(body, Zlib::DEFAULT_COMPRESSION)
      encoded_body = Base64.encode64(compressed_body)

      app_perf_agent_worker = AppPerfAgentWorker.new
      expect { app_perf_agent_worker.perform(params, encoded_body) }
        .to change {Application.count}.by(1)
        .and change{DatabaseType.count}.by(1)
        .and change{Trace.count}.by(2)
        .and change{Span.count}.by(10)

      trace = Trace.first
      expect(trace.spans.all? {|s| s.payload[:controller] == "TestController" }).to be(true)
    end

    it 'works with existing application' do
      user = User.create(:email => "user@example.com", :password => "password")
      application = create(:application, :name => "App Name")
      application.traces.create(:trace_key => "b07994fb2ece323877895abf7634479f6dfbac42")

      params = {
        "license_key" => application.license_key,
        "protocol_version" => 2
      }
      body = MessagePack.pack({
        "name" => "App Name",
        "host" => "localhost",
        "data" => [
          ["activerecord", "a0b1d8d48f4565e10484b452aee413400980768e", 1483021545.2476869, 0.8051395416259766, {"adapter" => "postgresql"}],
          ["activerecord", "a0b1d8d48f4565e10484b452aee413400980768e", 1483021545.25277, 0.5490779876708984, {"adapter" => "postgresql"}],
          ["activerecord", "a0b1d8d48f4565e10484b452aee413400980768e", 1483021545.26422, 2.6819705963134766, {"adapter" => "postgresql"}],
          ["actioncontroller", "a0b1d8d48f4565e10484b452aee413400980768e", 1483021545.2456489, 116.8220043182373, {}],
          ["rack", "a0b1d8d48f4565e10484b452aee413400980768e", 1483021545.220119, 143.70012283325195, {}],

          ["activerecord", "b0b1d8d48f4565e10484b452aee413400980768e", 1483021545.2476869, 0.8051395416259766, {"adapter" => "postgresql"}],
          ["activerecord", "b0b1d8d48f4565e10484b452aee413400980768e", 1483021545.25277, 0.5490779876708984, {"adapter" => "postgresql"}],
          ["activerecord", "b0b1d8d48f4565e10484b452aee413400980768e", 1483021545.26422, 2.6819705963134766, {"adapter" => "postgresql"}],
          ["actioncontroller", "b0b1d8d48f4565e10484b452aee413400980768e", 1483021545.2456489, 116.8220043182373, {}],
          ["rack", "b0b1d8d48f4565e10484b452aee413400980768e", 1483021545.220119, 143.70012283325195, {}],
        ]
      })

      compressed_body = Zlib::Deflate.deflate(body, Zlib::DEFAULT_COMPRESSION)
      encoded_body = Base64.encode64(compressed_body)

      app_perf_agent_worker = AppPerfAgentWorker.new
      expect { app_perf_agent_worker.perform(params, encoded_body) }
        .to change {Application.count}.by(0)
        .and change{DatabaseType.count}.by(1)
        .and change{Trace.count}.by(1)
        .and change{Span.count}.by(10)
    end
  end

end
