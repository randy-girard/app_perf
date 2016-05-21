# -*- encoding: utf-8 -*-

require 'rails_helper'

describe DatabaseSamplesController, :type => :controller do
  login_user

  # TODO: auto-generated
  describe 'GET index' do
    it 'works' do
      application = create(:application, :user => subject.current_user)
      database_call = create(:database_call, :application => application)

      get :index, :application_id => application, :database_id => database_call
      expect(response.status).to eq(200)
    end
  end

  # TODO: auto-generated
  describe 'GET show' do
    it 'works' do
      application = create(:application, :user => subject.current_user)
      database_call = create(:database_call, :application => application)
      database_sample = create(:transaction_sample_datum, :grouping => database_call)

      get :show, :application_id => application, :database_id => database_call, :id => database_sample
      expect(response.status).to eq(200)
    end
  end

end
