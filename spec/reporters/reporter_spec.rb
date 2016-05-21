# -*- encoding: utf-8 -*-

require 'spec_helper'

describe Reporter do

  # TODO: auto-generated
  describe '#new' do
    it 'works' do
      application = double('application')
      params = double('params')
      view_context = double('view_context')
      result = Reporter.new(application, params, view_context)
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#render' do
    it 'returns nil' do
      application = double('application')
      params = double('params')
      view_context = double('view_context')
      reporter = Reporter.new(application, params, view_context)
      result = reporter.render
      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#report_data' do
    it 'works' do
      application = double('application')
      params = double('params')
      view_context = double('view_context')
      reporter = Reporter.new(application, params, view_context)
      result = reporter.report_data
      expect(result).not_to be_nil
    end
  end

end
