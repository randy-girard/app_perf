# -*- encoding: utf-8 -*-

require 'spec_helper'

describe DurationReporter do

  # TODO: auto-generated
  describe '#render' do
    it 'works' do
      application = create(:application)

      params = {}
      duration_reporter = DurationReporter.new(application, params)
      duration_reporter.render
    end
  end

  # TODO: auto-generated
  describe '#report_data' do
    it 'works' do
      application = create(:application)

      params = {}
      duration_reporter = DurationReporter.new(application, params)
      result = duration_reporter.report_data
      expect(result).not_to be_nil
    end
  end

end
