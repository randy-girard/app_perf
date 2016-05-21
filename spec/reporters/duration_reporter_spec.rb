# -*- encoding: utf-8 -*-

require 'spec_helper'

describe DurationReporter do

  # TODO: auto-generated
  describe '#render' do
    it 'works' do
      application = double('application')
      expect(application).to receive(:transaction_data)
      params = double('params')
      expect(params).to receive(:[])
      view_context = double('view_context')
      expect(view_context).to receive(:area_chart)
      duration_reporter = DurationReporter.new(application, params, view_context)
      duration_reporter.render
    end
  end

  # TODO: auto-generated
  describe '#report_data' do
    it 'works' do
      application = double('application')
      expect(application).to receive(:transaction_data)
      params = double('params')
      expect(params).to receive(:[])
      view_context = double('view_context')
      duration_reporter = DurationReporter.new(application, params, view_context)
      result = duration_reporter.report_data
      expect(result).not_to be_nil
    end
  end

end
