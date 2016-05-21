# -*- encoding: utf-8 -*-

require 'spec_helper'

describe DatabaseReporter do

  # TODO: auto-generated
  describe '#render' do
    it 'works' do
      application = create(:application)
      database_call = create(:database_call, :application => application)
      params = double('params')
      view_context = double('view_context')
      expect(view_context).to receive(:area_chart)
      database_reporter = DatabaseReporter.new(application, params, view_context)
      database_reporter.render
    end
  end

  # TODO: auto-generated
  describe '#report_data' do
    it 'works' do
      application = create(:application)
      database_call = create(:database_call, :application => application)
      params = double('params')
      view_context = double('view_context')
      database_reporter = DatabaseReporter.new(application, params, view_context)
      result = database_reporter.report_data
      expect(result).not_to be_nil
    end
  end

end
