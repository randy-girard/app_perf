require 'rails_helper'

RSpec.describe "organizations/index", type: :view do
  before(:each) do
    assign(:organizations, [
      Organization.create!(
        :user => nil,
        :name => "Name"
      ),
      Organization.create!(
        :user => nil,
        :name => "Name"
      )
    ])
  end

  it "renders a list of organizations" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "Name".to_s, :count => 2
  end
end
