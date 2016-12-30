# -*- encoding: utf-8 -*-

require 'rails_helper'

describe AgentListenerController do

  # TODO: auto-generated
  describe 'POST create' do
    it 'works' do
      application = create(:application)

      post :create, {
          :protocol_version => 2,
          :license_key => application.license_key
        }, {}
      expect(response.status).to eq(200)
    end
  end
end
