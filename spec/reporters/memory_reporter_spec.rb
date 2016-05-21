# -*- encoding: utf-8 -*-

require 'spec_helper'

describe MemoryReporter do

  # TODO: auto-generated
  describe '#render' do
    it 'works' do
      application = create(:application)
      analytic_event_data = create(:analytic_event_datum, :application => application)
      params = double('params')
      view_context = double('view_context')
      expect(view_context).to receive(:area_chart)
      memory_reporter = MemoryReporter.new(application, params, view_context)
      memory_reporter.render
    end
  end

  # TODO: auto-generated
  describe '#report_data' do
    it 'works' do
      application = create(:application)
      analytic_event_data = create(:analytic_event_datum, :application => application)
      params = double('params')
      view_context = double('view_context')
      memory_reporter = MemoryReporter.new(application, params, view_context)
      result = memory_reporter.report_data
      expect(result).not_to be_nil
    end
  end

end
