# -*- encoding: utf-8 -*-

require 'rails_helper'

describe Organizations::Applications::ErrorsController, :type => :controller do
  login_user

  # TODO: auto-generated
  describe 'GET index' do
    it 'works' do
      organization = create(:organization, :user => subject.current_user)
      application = create(:application, :organization => organization)
      create(:error_message, :application => application)

      get :index, :organization_id => organization, :application_id => application
      expect(response.status).to eq(200)
    end
  end

  # TODO: auto-generated
  describe 'GET show' do
    it 'works' do
      organization = create(:organization, :user => subject.current_user)
      application = create(:application, :organization => organization)
      error_datum = create(:error_datum, :application => application)


      get :show, :organization_id => organization, :application_id => application, :id => error_datum
      expect(response.status).to eq(200)
    end
  end

end
