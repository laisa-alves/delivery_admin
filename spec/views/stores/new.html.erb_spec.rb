require 'rails_helper'

RSpec.describe 'stores/new', type: :view do
  context 'when user is seller' do
    let(:seller) do
      seller = User.create!(
        email: 'seller@email.com',
        password: '123456',
        password_confirmation: '123456',
        role: :seller
      )
      seller
    end

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
    let(:admin) do
      admin = User.create!(
        email: 'admin@email.com',
        password: '123456',
        password_confirmation: '123456',
        role: :admin
      )
      admin
    end

    let(:sellers) do
      [
        User.create!(
          email: 'seller1@email.com',
          password: '123456',
          password_confirmation: '123456',
          role: :seller
        ),
        User.create!(
          email: 'seller2@email.com',
          password: '123456',
          password_confirmation: '123456',
          role: :seller
        ),
        User.create!(
          email: 'seller3@email.com',
          password: '123456',
          password_confirmation: '123456',
          role: :seller
        )
      ]
    end

    before(:each) do
      allow(view).to receive(:current_user).and_return(admin)
      assign(:store, Store.new(name: 'MyString'))
      assign(:sellers, sellers)
    end

    it "renders new store form with seller select field" do
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
