# -*- encoding: utf-8 -*-

require 'rails_helper'

describe TransactionSamplesController, :type => :controller do
  login_user

  # TODO: auto-generated
  describe 'GET show' do
    it 'works' do
      application = create(:application, :user => subject.current_user)
      transaction_endpoint = create(:transaction_endpoint, :application => application)
      transaction_sample_datum = create(:transaction_sample_datum, :transaction_endpoint => transaction_endpoint, :application => application)

      get :show, :application_id => application, :transaction_id => transaction_endpoint, :id => transaction_sample_datum
      expect(response.status).to eq(200)
    end
  end

end
