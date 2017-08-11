# -*- encoding: utf-8 -*-

require 'rails_helper'

describe ReportsController, :type => :controller do
  login_user

  # TODO: auto-generated
  describe 'GET show' do
    it 'works' do
      organization = create(:organization, :user => subject.current_user)
      application = create(:application, :organization => organization)

      get :show, :organization_id => organization, :application_id => application, :id => "duration"
      expect(response.status).to eq(200)
    end
  end

  # TODO: auto-generated
  describe 'GET new' do
    it 'works' do
      expect(Application).to receive(:select).with("pg_sleep(5)") { [1] }
      organization = create(:organization, :user => subject.current_user)
      application = create(:application, :organization => organization)

      get :new, :organization_id => organization, :application_id => application
      expect(response.status).to eq(200)
    end
  end

  # TODO: auto-generated
  describe 'GET error' do
    it 'works' do
      organization = create(:organization, :user => subject.current_user)
      application = create(:application, :organization => organization)

      expect {
        get :error, :organization_id => organization, :application_id => application
      }.to raise_error(RuntimeError)
    end
  end

end
