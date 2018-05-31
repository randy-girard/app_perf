require 'rails_helper'

RSpec.describe OrganizationsController, type: :controller do
  login_user

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # OrganizationsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all organizations as @organizations" do
      organization = create(:organization, :user => subject.current_user)
      get :index, {}, valid_session
      expect(assigns(:organizations)).to eq([organization])
    end
  end

  describe "GET #new" do
    it "assigns a new organization as @organization" do
      get :new, {}, valid_session
      expect(assigns(:organization)).to be_a_new(Organization)
    end
  end

  describe "GET #edit" do
    it "assigns the requested organization as @organization" do
      organization = create(:organization, :user => subject.current_user)
      get :edit, {:id => organization.to_param}, valid_session
      expect(assigns(:organization)).to eq(organization)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Organization" do
        expect {
          post :create, {:organization => attributes_for(:organization)}, valid_session
        }.to change(Organization, :count).by(1)
      end

      it "assigns a newly created organization as @organization" do
        post :create, {:organization => attributes_for(:organization)}, valid_session
        expect(assigns(:organization)).to be_a(Organization)
        expect(assigns(:organization)).to be_persisted
      end

      it "redirects to the created organization" do
        post :create, {:organization => attributes_for(:organization)}, valid_session
        expect(response).to redirect_to(edit_organization_path(Organization.last))
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      it "assigns the requested organization as @organization" do
        organization = create(:organization, :user => subject.current_user)
        put :update, {:id => organization.to_param, :organization => attributes_for(:organization)}, valid_session
        expect(assigns(:organization)).to eq(organization)
      end

      it "redirects to the organization" do
        organization = create(:organization, :user => subject.current_user)
        put :update, {:id => organization.to_param, :organization => attributes_for(:organization)}, valid_session
        expect(response).to redirect_to(edit_organization_path(organization))
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested organization" do
      organization = create(:organization, :user => subject.current_user)
      expect {
        delete :destroy, {:id => organization.to_param}, valid_session
      }.to change(Organization, :count).by(-1)
    end

    it "redirects to the organizations list" do
      organization = create(:organization, :user => subject.current_user)
      delete :destroy, {:id => organization.to_param}, valid_session
      expect(response).to redirect_to(organizations_url)
    end
  end

end
