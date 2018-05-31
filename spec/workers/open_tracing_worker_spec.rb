# -*- encoding: utf-8 -*-
require "rails_helper"

describe OpenTracingWorker do

  describe '#perform' do
    it "should process traces" do
      application = create(:application, :license_key => "1")

      body = eval(File.read(Rails.root.join("spec", "factories", "open_tracing_trace.json")))

      params = {
        "license_key" => application.license_key,
        "protocol_version" => "3"
      }

      expect { OpenTracingWorker.perform_now(params, body) }
        .to change { Backtrace.count }.by(4)
        .and change { Span.count }.by(6)
        .and change { LogEntry.count }.by(8)
        .and change { Trace.count }.by(1)

      #Span.all.each do |s|
      #  puts [s.uuid, s.source.length, s.backtrace.backtrace.length, s.duration, s.exclusive_duration].inspect
      #end

      data = [
        ["e5170f65ba1c8510", 1, 1, 9.22608375549316, 9.22608375549316],
        ["f5130aa4f5927a", 2, 2, 9.68074798583984, 9.68074798583984],
        ["f31eab7afb85ed3d", 2, 2, 18.9278125762939, 18.9278125762939],
        ["506548acd9ea836e", 2, 2, 5008.93211364746, 5008.93211364746]
      ]
      data.each_with_index do |datum, index|
        span = Span.find_by_uuid(datum[0])
        expect(span.source.length).to eq(datum[1])
        expect(span.backtrace.backtrace.length).to eq(datum[2])
        expect(span.duration).to eq(datum[3])
        expect(span.exclusive_duration).to eq(datum[4])
      end
    end

    it "should process log entry as error" do
      application = create(:application, :license_key => "1")

      body = eval(File.read(Rails.root.join("spec", "factories", "open_tracing_error.json")))

      params = {
        "license_key" => application.license_key,
        "protocol_version" => "3"
      }

      expect { OpenTracingWorker.perform_now(params, body) }
        .to change { Backtrace.count }.by(3)
        .and change { Span.count }.by(17)
        .and change { LogEntry.count }.by(7)
        .and change { Trace.count }.by(1)
        .and change { ErrorMessage.count }.by(1)
        .and change { ErrorDatum.count }.by(1)

      span = Span.all.find {|span| span.tag("error") == true }
      expect(span.duration).to eq(45.9530353546143)
      expect(span.error).to eq(ErrorDatum.last)
    end
  end

  describe "#span_children_data" do
    it "should gather children" do
      span = { "id" => "1" }
      data = [
        { "id" => "2", "parentId" => "1" },
        { "id" => "3", "parentId" => "2" },
        { "id" => "4", "parentId" => "3" },
        { "id" => "5", "parentId" => "1" }
      ]

      worker = OpenTracingWorker.new
      expect(worker.send(:span_children_data, span, data)).to eq([
        { "id" => "2", "parentId" => "1" },
        { "id" => "5", "parentId" => "1" }
      ])
    end
  end

  describe "#get_exclusive_duration" do
    it "should not infinite loop if child and span have same id" do
      span = { "id" => "1", "duration" => 6000 }
      data = [
        { "id" => "1", "parentId" => "1", "duration" => 1000 },
        { "id" => "2", "parentId" => "2", "duration" => 2000 },
        { "id" => "3", "parentId" => "3", "duration" => 3000 },
        { "id" => "4", "parentId" => "1", "duration" => 4000 }
      ]

      worker = OpenTracingWorker.new
      expect(worker.send(:get_exclusive_duration, span, data)).to eq(2000)
    end

    it "should calculate exclusive duration properly" do
      span = { "id" => "1", "duration" => 10000 }
      data = [
        { "id" => "2", "parentId" => "1", "duration" => 1000 }, # 0
        { "id" => "3", "parentId" => "2", "duration" => 3000 }, # 1000
        { "id" => "4", "parentId" => "3", "duration" => 2000 }, # 2000
        { "id" => "5", "parentId" => "1", "duration" => 4000 }  # 4000
      ]

      worker = OpenTracingWorker.new
      expect(worker.send(:get_exclusive_duration, span, data)).to eq(5000)
    end
  end
end
