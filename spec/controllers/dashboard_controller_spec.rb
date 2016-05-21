# -*- encoding: utf-8 -*-

require 'rails_helper'

describe DashboardController, :type => :controller do
  login_user

  # TODO: auto-generated
  describe 'GET show' do
    it 'works' do
      get :show, {}, {}
      expect(response.status).to eq(200)
    end
  end

end
