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

      data = [
        ["6445831bae7fcafe", 2, 500, 5138.04697990417, 11.208057403559906],
        ["5be9cc485d202d0", 2, 4716, 5126.83892250061, 11.83009147643861],
        ["7dc84d604a73ad78", 316, 8985, 10.3209018707275, 10.3209018707275],
        ["762f86b1c423dce2", 809, 9096, 12.437105178833, 12.437105178833],
        ["31e8c10792c9ce0b", 828, 9095, 11.9228363037109, 11.9228363037109],
        ["a5f32654a51d6ffa", 623, 9068, 5080.3279876709, 5080.3279876709],
        ["67a169f8dc7c355d", 2, 500, 2.39777565002441, 2.39777565002441]
      ]
      data.each_with_index do |datum, index|
        span = Span.find_by_uuid(datum[0])
        expect(span.source.to_s.length).to eq(datum[1])
        expect(span.backtrace.backtrace.to_s.length).to eq(datum[2])
        expect(span.duration).to eq(datum[3])
        expect(span.exclusive_duration).to eq(datum[4])
      end
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
