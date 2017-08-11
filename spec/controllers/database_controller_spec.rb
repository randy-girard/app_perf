# -*- encoding: utf-8 -*-

require 'rails_helper'

describe DatabaseController, :type => :controller do
  login_user

  # TODO: auto-generated
  describe 'GET index' do
    it 'works' do
      organization = create(:organization, :user => subject.current_user)
      application = create(:application, :organization => organization)

      get :index, :organization_id => organization, :application_id => application
      expect(response.status).to eq(200)
    end
  end

end
