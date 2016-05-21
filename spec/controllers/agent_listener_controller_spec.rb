# -*- encoding: utf-8 -*-

require 'rails_helper'

describe AgentListenerController do

  # TODO: auto-generated
  describe 'POST create' do
    it 'works' do
      post :create, {}, {}
      expect(response.status).to eq(200)
    end
  end

  # TODO: auto-generated
  describe 'GET invoke_raw_method' do
    it 'works' do
      get :invoke_raw_method, {}, {}
      expect(response.status).to eq(200)
    end
  end

end
