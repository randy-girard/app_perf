# -*- encoding: utf-8 -*-

require 'rails_helper'

describe ReportsController, :type => :controller do
  login_user

  # TODO: auto-generated
  describe 'GET show' do
    it 'works' do
      application = create(:application, :user => subject.current_user)

      get :show, :application_id => application, :id => "duration"
      expect(response.status).to eq(200)
    end
  end

  # TODO: auto-generated
  describe 'GET new' do
    it 'works' do
      expect(Application).to receive(:select).with("pg_sleep(5)") { [1] }
      application = create(:application, :user => subject.current_user)

      get :new, :application_id => application
      expect(response.status).to eq(200)
    end
  end

  # TODO: auto-generated
  describe 'GET error' do
    it 'works' do
      application = create(:application, :user => subject.current_user)

      expect {
        get :error, :application_id => application
      }.to raise_error(RuntimeError)
    end
  end

end
