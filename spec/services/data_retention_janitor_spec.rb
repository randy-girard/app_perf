# -*- encoding: utf-8 -*-
require "rails_helper"

describe DataRetentionJanitor do
  let(:user) { create(:user) }
  let(:application) { create(:application, :user => user) }

  subject { DataRetentionJanitor.new }

  context "application has a data retention date" do
    it "should remove data older than data retention date" do
      application.traces.create(:trace_key => "1", :timestamp => 2.hours.ago)
      application.traces.create(:trace_key => "2", :timestamp => 30.minutes.ago)

      expect {
        subject.perform(application.id)
      }.to change { Trace.count }.by(-1)
    end
  end

  context "application does not have a data retention date" do
    let(:application) {
      create(:application, :user => user, :data_retention_hours => nil)
    }

    it "should remove data older than data retention date" do
      application.traces.create(:trace_key => "1", :timestamp => 2.hours.ago)

      expect {
        subject.perform(application.id)
      }.to change { Trace.count }.by(0)
    end
  end
end
