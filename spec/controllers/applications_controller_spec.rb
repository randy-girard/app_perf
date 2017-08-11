# -*- encoding: utf-8 -*-

require 'rails_helper'

describe ApplicationsController, :type => :controller do
  login_user

  # TODO: auto-generated
  describe 'GET index' do
    it 'works' do
      organization = create(:organization, :user => subject.current_user)

      get :index, :organization_id => organization
      expect(response.status).to eq(200)
    end
  end

  # TODO: auto-generated
  describe 'GET new' do
    it 'works' do
      organization = create(:organization, :user => subject.current_user)
      get :new, :organization_id => organization
      expect(response.status).to eq(200)
    end
  end

  # TODO: auto-generated
  describe 'GET edit' do
    it 'works' do
      organization = create(:organization, :user => subject.current_user)
      application = create(:application, :organization => organization)
      get :edit, :organization_id => organization, :id => application
      expect(response.status).to eq(200)
    end
  end

  # TODO: auto-generated
  describe 'PUT update' do
    it 'works' do
      organization = create(:organization, :user => subject.current_user)
      application = create(:application, :organization => organization)
      put :update, :organization_id => organization, :id => application, :application => { :name => "Test" }
      expect(response.status).to eq(302)
      expect(response).to redirect_to(edit_organization_application_path(organization, application))
    end
  end

  # TODO: auto-generated
  describe 'DELETE destroy' do
    it 'works' do
      organization = create(:organization, :user => subject.current_user)
      application = create(:application, :organization => organization)
      delete :destroy, :organization_id => organization, :id => application
      expect(response.status).to eq(302)
      expect(response).to redirect_to(organization_applications_path(organization))
    end
  end

end
