# -*- encoding: utf-8 -*-
require "rails_helper"

describe AppPerfAgentWorker do

  # TODO: auto-generated
  describe '#perform' do
    context "trace header is set" do

    end
    it 'works' do
      user = User.create(:email => "user@example.com", :password => "password")
      organization = create(:organization, :user => user)

      params = {
        "license_key" => organization.license_key,
        "protocol_version" => 2
      }

      body = Oj.dump({
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
          ["rack", "b0b1d8d48f4565e10484b452aee413400980768e", 1483021545.220119, 143.70012283325195, {}]
        ]
      })

      compressed_body = Zlib::Deflate.deflate(body, Zlib::DEFAULT_COMPRESSION)
      encoded_body = Base64.encode64(compressed_body)

      app_perf_agent_worker = AppPerfAgentWorker.new
      expect(app_perf_agent_worker).to receive(:perform_data_retention_cleanup).never
      expect { app_perf_agent_worker.perform(params, encoded_body) }
        .to change {Application.count}.by(1)
        .and change{DatabaseType.count}.by(1)
        .and change{Trace.count}.by(2)
        .and change{TransactionSampleDatum.count}.by(10)

      trace = Trace.first
      samples = trace.arrange_samples.dump_attribute_tree(:layer_name)
      expect(samples).to eq([
        "rack", {
          :children=>[
            "actioncontroller", {
              :children=>["activerecord", "activerecord", "activerecord"]
            }
          ]
        }
      ])
      expect(trace.transaction_sample_data.all? {|s| s.controller == "TestController" }).to be(true)
    end

    it 'works with existing application' do
      user = User.create(:email => "user@example.com", :password => "password")
      organization = create(:organization, :user => user)
      application = create(:application, :organization => organization, :user => user, :name => "App Name", :data_retention_hours => nil)
      application.traces.create(:trace_key => "b07994fb2ece323877895abf7634479f6dfbac42")

      params = {
        "license_key" => organization.license_key,
        "protocol_version" => 2
      }
      body = Oj.dump({
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
          ["rack", "b0b1d8d48f4565e10484b452aee413400980768e", 1483021545.220119, 143.70012283325195, {}]
        ]
      })

      compressed_body = Zlib::Deflate.deflate(body, Zlib::DEFAULT_COMPRESSION)
      encoded_body = Base64.encode64(compressed_body)

      app_perf_agent_worker = AppPerfAgentWorker.new
      expect(app_perf_agent_worker).to receive(:perform_data_retention_cleanup).never
      expect { app_perf_agent_worker.perform(params, encoded_body) }
        .to change {Application.count}.by(0)
        .and change{DatabaseType.count}.by(1)
        .and change{Trace.count}.by(1)
        .and change{TransactionSampleDatum.count}.by(10)

      samples = Trace.first.arrange_samples.dump_attribute_tree(:layer_name)
      expect(samples).to eq([
        "rack", {
          :children=>[
            "actioncontroller", {
              :children=>["activerecord", "activerecord", "activerecord"]
            }
          ]
        }
      ])
      samples = Trace.first.arrange_samples.dump_attribute_tree([:exclusive_duration, [:round, 5]])
      expect(samples).to eq([
        26.87812, {
          :children=>[
            112.78582, {
              :children=>[0.54908, 0.80514, 2.68197]
            }
          ]
        }
      ])
    end
  end

end
