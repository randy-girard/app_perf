# -*- encoding: utf-8 -*-

require 'rails_helper'

describe SessionsController, :type => :controller do

  # TODO: auto-generated
  describe 'GET new' do
    it 'works' do
      get :new
      expect(response.status).to eq(200)
    end
  end

  # TODO: auto-generated
  describe 'POST create' do
    it 'works' do
      user = create(:user)

      post :create, { :email => user.email, :password => "password" }
      expect(response.status).to eq(302)
      expect(response).to redirect_to(root_url)
    end
  end

  # TODO: auto-generated
  describe 'DELETE destroy' do
    login_user

    it 'works' do
      delete :destroy
      expect(response.status).to eq(302)
      expect(response).to redirect_to(new_user_session_url)
    end
  end

end
