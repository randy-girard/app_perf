# -*- encoding: utf-8 -*-

require 'spec_helper'

describe Reporter do

  describe '#new' do
    it 'works' do
      application = double('application')
      params = {}
      result = Reporter.new(application, params)
      expect(result).not_to be_nil
    end
  end

  describe '#report_data' do
    it 'works' do
      application = double('application')
      params = {}
      reporter = Reporter.new(application, params)
      result = reporter.report_data
      expect(result).not_to be_nil
    end
  end

end
