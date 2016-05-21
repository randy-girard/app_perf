# -*- encoding: utf-8 -*-

require 'spec_helper'

describe AppPerfAgentWorker do

  # TODO: auto-generated
  describe '#perform' do
    it 'works' do
      app_perf_agent_worker = AppPerfAgentWorker.new
      params = double('params')
      expect(params).to receive(:fetch).exactly(5).times
      app_perf_agent_worker.perform(params)
    end
  end

end
