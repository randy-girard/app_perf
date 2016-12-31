# -*- encoding: utf-8 -*-
require "rails_helper"

describe AppPerfAgentWorker do

  # TODO: auto-generated
  describe '#perform' do
    it 'works' do
      user = User.create(:email => "user@example.com", :password => "password")

      params = {
        :license_key => user.license_key,
        :name => "App Name",
        :protocol_version => 2,
        :host => "localhost",
        :data => [
          ["activerecord", "a0b1d8d48f4565e10484b452aee413400980768e", 1483021545.2476869, 0.8051395416259766, "{\"adapter\":\"postgresql\"}"],
          ["activerecord", "a0b1d8d48f4565e10484b452aee413400980768e", 1483021545.25277, 0.5490779876708984, "{\"adapter\":\"postgresql\"}"],
          ["activerecord", "a0b1d8d48f4565e10484b452aee413400980768e", 1483021545.26422, 2.6819705963134766, "{\"adapter\":\"postgresql\"}"],
          ["actioncontroller", "a0b1d8d48f4565e10484b452aee413400980768e", 1483021545.2456489, 116.8220043182373, "{}"],
          ["rack", "a0b1d8d48f4565e10484b452aee413400980768e", 1483021545.220119, 143.70012283325195, "{}"],

          ["activerecord", "b0b1d8d48f4565e10484b452aee413400980768e", 1483021545.2476869, 0.8051395416259766, "{\"adapter\":\"postgresql\"}"],
          ["activerecord", "b0b1d8d48f4565e10484b452aee413400980768e", 1483021545.25277, 0.5490779876708984, "{\"adapter\":\"postgresql\"}"],
          ["activerecord", "b0b1d8d48f4565e10484b452aee413400980768e", 1483021545.26422, 2.6819705963134766, "{\"adapter\":\"postgresql\"}"],
          ["actioncontroller", "b0b1d8d48f4565e10484b452aee413400980768e", 1483021545.2456489, 116.8220043182373, "{}"],
          ["rack", "b0b1d8d48f4565e10484b452aee413400980768e", 1483021545.220119, 143.70012283325195, "{}"]
        ]
      }

      app_perf_agent_worker = AppPerfAgentWorker.new
      expect(app_perf_agent_worker).to receive(:perform_data_retention_cleanup).once
      expect { app_perf_agent_worker.perform(params) }
        .to change {Application.count}.by(1)
        .and change{DatabaseType.count}.by(1)
        .and change{Trace.count}.by(2)
        .and change{TransactionSampleDatum.count}.by(10)

      samples = Trace.first.root_sample.dump_attribute_tree(:layer_name)
      expect(samples).to eq([
        "rack", {
          :children=>[
            "actioncontroller", {
              :children=>["activerecord", "activerecord", "activerecord"]
            }
          ]
        }
      ])
    end

    it 'works with existing application' do
      user = User.create(:email => "user@example.com", :password => "password")
      application = create(:application, :user => user, :name => "App Name", :data_retention_hours => nil)
      application.traces.create(:trace_key => "b0b1d8d48f4565e10484b452aee413400980768e")

      params = {
        :license_key => user.license_key,
        :name => "App Name",
        :protocol_version => 2,
        :host => "localhost",
        :data => [
          ["activerecord", "a0b1d8d48f4565e10484b452aee413400980768e", 1483021545.2476869, 0.8051395416259766, "{\"adapter\":\"postgresql\"}"],
          ["activerecord", "a0b1d8d48f4565e10484b452aee413400980768e", 1483021545.25277, 0.5490779876708984, "{\"adapter\":\"postgresql\"}"],
          ["activerecord", "a0b1d8d48f4565e10484b452aee413400980768e", 1483021545.26422, 2.6819705963134766, "{\"adapter\":\"postgresql\"}"],
          ["actioncontroller", "a0b1d8d48f4565e10484b452aee413400980768e", 1483021545.2456489, 116.8220043182373, "{}"],
          ["rack", "a0b1d8d48f4565e10484b452aee413400980768e", 1483021545.220119, 143.70012283325195, "{}"],

          ["activerecord", "b0b1d8d48f4565e10484b452aee413400980768e", 1483021545.2476869, 0.8051395416259766, "{\"adapter\":\"postgresql\"}"],
          ["activerecord", "b0b1d8d48f4565e10484b452aee413400980768e", 1483021545.25277, 0.5490779876708984, "{\"adapter\":\"postgresql\"}"],
          ["activerecord", "b0b1d8d48f4565e10484b452aee413400980768e", 1483021545.26422, 2.6819705963134766, "{\"adapter\":\"postgresql\"}"],
          ["actioncontroller", "b0b1d8d48f4565e10484b452aee413400980768e", 1483021545.2456489, 116.8220043182373, "{}"],
          ["rack", "b0b1d8d48f4565e10484b452aee413400980768e", 1483021545.220119, 143.70012283325195, "{}"]
        ]
      }

      app_perf_agent_worker = AppPerfAgentWorker.new
      expect(app_perf_agent_worker).to receive(:perform_data_retention_cleanup).once
      expect { app_perf_agent_worker.perform(params) }
        .to change {Application.count}.by(0)
        .and change{DatabaseType.count}.by(1)
        .and change{Trace.count}.by(1)
        .and change{TransactionSampleDatum.count}.by(10)

      samples = Trace.first.root_sample.dump_attribute_tree(:layer_name)
      expect(samples).to eq([
        "rack", {
          :children=>[
            "actioncontroller", {
              :children=>["activerecord", "activerecord", "activerecord"]
            }
          ]
        }
      ])
    end
  end

end
