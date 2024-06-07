require 'rails_helper'

RSpec.describe 'stores/new', type: :view do
  context 'when user is seller' do
    let(:seller) { create(:user, role: :seller) }

    before(:each) do
      allow(view).to receive(:current_user).and_return(seller)
      assign(:store, Store.new(name: 'MyString'))
    end

    it 'renders new store form' do
      render

      assert_select 'form[action=?][method=?]', stores_path, 'post' do
        assert_select 'input[name=?]', 'store[name]'
      end
    end
  end

  context 'when user is admin' do
    let(:admin) { create(:user) }
    let(:sellers) { create_list(:user, 3, role: :seller) }

    before(:each) do
      allow(view).to receive(:current_user).and_return(admin)
      assign(:store, Store.new(name: 'MyString'))
      assign(:sellers, sellers)
    end

    skip it "renders new store form with seller select field" do
      render

      assert_select "form[action=?][method=?]", stores_path, "post" do
        assert_select "input[name=?]", "store[name]"
        assert_select "select[name=?]", "store[user_id]" do
          sellers.each do |seller|
            assert_select "option[value=?]", seller.id.to_s, text: seller.email
          end
        end
      end
    end
  end
end
