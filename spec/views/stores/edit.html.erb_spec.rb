require 'rails_helper'

RSpec.describe "stores/edit", type: :view do
  let(:seller) { create(:user, role: :seller) }

  let(:store) {create(:store, user: seller)}

  before(:each) do
    allow(view).to receive(:current_user).and_return(seller)
    assign(:store, store)
  end

  it "renders the edit store form" do
    render

    assert_select "form[action=?][method=?]", store_path(store), "post" do

      assert_select "input[name=?]", "store[name]"
    end
  end
end
