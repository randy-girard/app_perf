# -*- encoding: utf-8 -*-

require 'rails_helper'

describe ErrorInstancesController, :type => :controller do
  login_user

  # TODO: auto-generated
  describe 'GET index' do
    it 'works' do
      application = create(:application)
      error_message = create(:error_message, :application => application)
      create(:error_datum, :application => application, :error_message => error_message)

      get :index, :application_id => application, :error_id => error_message
      expect(response.status).to eq(200)
    end
  end

  # TODO: auto-generated
  describe 'GET show' do
    it 'works' do
      application = create(:application)
      error_message = create(:error_message, :application => application)
      error_datum = create(:error_datum, :application => application, :error_message => error_message)
      get :show, :application_id => application, :error_id => error_message, :id => error_datum
      expect(response.status).to eq(200)
    end
  end

end
