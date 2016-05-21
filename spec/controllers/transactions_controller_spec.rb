# -*- encoding: utf-8 -*-

require 'rails_helper'

describe TransactionsController, :type => :controller do
  login_user

  # TODO: auto-generated
  describe 'GET index' do
    it 'works' do
      application = create(:application, :user => subject.current_user)

      get :index, :application_id => application
      expect(response.status).to eq(200)
    end
  end

  # TODO: auto-generated
  describe 'GET show' do
    it 'works' do
      application = create(:application, :user => subject.current_user)
      transaction_endpoint = create(:transaction_endpoint, :application => application)

      get :show, :application_id => application, :id => transaction_endpoint

      expect(response.status).to eq(200)
    end
  end

end
