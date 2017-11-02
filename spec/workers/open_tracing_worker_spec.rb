# -*- encoding: utf-8 -*-
require "rails_helper"

describe OpenTracingWorker do

  describe '#perform' do
    it "should process traces" do
      organization = create(:organization, :license_key => "1")
      application = create(:application, :organization => organization)

      body = eval(File.read(Rails.root.join("spec", "factories", "open_tracing_trace.json")))

      params = {
        "license_key" => organization.license_key,
        "protocol_version" => "3"
      }

      expect { OpenTracingWorker.perform_now(params, body) }
        .to change { Backtrace.count }.by(7)
        .and change { Span.count }.by(7)
        .and change { LogEntry.count }.by(14)
        .and change { Trace.count }.by(2)

      span = Span.find_by_uuid("67a169f8dc7c355d")
      expect(span.source.to_s.length).to eq(2)
      expect(span.backtrace.backtrace.to_s.length).to eq(500)
      expect(span.duration).to eq(2.39777565002441)
    end

    it "should process log entry as error" do
      organization = create(:organization, :license_key => "1")
      application = create(:application, :organization => organization)

      body = eval(File.read(Rails.root.join("spec", "factories", "open_tracing_error.json")))

      params = {
        "license_key" => organization.license_key,
        "protocol_version" => "3"
      }

      expect { OpenTracingWorker.perform_now(params, body) }
        .to change { Backtrace.count }.by(17)
        .and change { Span.count }.by(17)
        .and change { LogEntry.count }.by(35)
        .and change { Trace.count }.by(1)
        .and change { ErrorMessage.count }.by(1)
        .and change { ErrorDatum.count }.by(1)

      span = Span.all.find {|span| span.tag("error") == true }
      expect(span.source.to_s.length).to eq(2)
      expect(span.backtrace.backtrace.to_s.length).to eq(4716)
      expect(span.duration).to eq(45.8791255950928)
      expect(span.error).to eq(ErrorDatum.last)

    end
  end

  describe "children_duration" do
    it "should sum up durations" do
      children = [
        { "duration" => 1000 },
        { "duration" => 2000 },
        { "duration" => 3000 }
      ]

      worker = OpenTracingWorker.new
      expect(worker.send(:children_duration, children)).to eq(6.0)
    end
  end

  describe "#span_children_data" do
    it "should gather children" do
      span = Span.new(:uuid => "1")
      data = [
        { "id" => "1", "parentId" => "1" },
        { "id" => "2", "parentId" => "2" },
        { "id" => "3", "parentId" => "3" },
        { "id" => "4", "parentId" => "1" }
      ]

      worker = OpenTracingWorker.new
      expect(worker.send(:span_children_data, span, data)).to eq([
        { "id" => "1", "parentId" => "1" },
        { "id" => "4", "parentId" => "1" }
      ])
    end
  end

  describe "#get_exclusive_duration" do
    it "should calculate exclusive duration properly" do
      span = Span.new(:uuid => "1", :duration => 6.0)
      data = [
        { "id" => "1", "parentId" => "1", "duration" => 1000 },
        { "id" => "2", "parentId" => "2", "duration" => 2000 },
        { "id" => "3", "parentId" => "3", "duration" => 3000 },
        { "id" => "4", "parentId" => "1", "duration" => 4000 }
      ]

      worker = OpenTracingWorker.new
      expect(worker.send(:get_exclusive_duration, span, data)).to eq(1.0)
    end
  end
end
