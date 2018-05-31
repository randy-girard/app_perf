# -*- encoding: utf-8 -*-

require 'rails_helper'

describe ErrorsController, :type => :controller do
  login_user

  # TODO: auto-generated
  describe 'GET index' do
    it 'works' do
      application = create(:application)
      create(:error_message, :application => application)

      get :index, :application_id => application
      expect(response.status).to eq(200)
    end
  end

  # TODO: auto-generated
  describe 'GET show' do
    it 'works' do
      application = create(:application)
      error_datum = create(:error_datum, :application => application)


      get :show, :application_id => application, :id => error_datum
      expect(response.status).to eq(200)
    end
  end

end
