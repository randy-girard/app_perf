# -*- encoding: utf-8 -*-

require 'spec_helper'

describe ErrorReporter do

  # TODO: auto-generated
  describe '#render' do
    it 'works' do
      application = create(:application)
      analytic_event_data = create(:analytic_event_datum, :application => application, :name => "Error", :timestamp => Time.now - 5.minutes)
      params = {}
      view_context = double('view_context')
      expect(view_context).to receive(:area_chart)
      error_reporter = ErrorReporter.new(application, params, view_context)
      error_reporter.render
    end
  end

  # TODO: auto-generated
  describe '#report_data' do
    it 'works' do
      application = create(:application)
      analytic_event_data = create(:analytic_event_datum, :application => application, :name => "Error")
      params = {}
      view_context = double('view_context')
      error_reporter = ErrorReporter.new(application, params, view_context)
      result = error_reporter.report_data
      expect(result).not_to be_nil
    end
  end

end
