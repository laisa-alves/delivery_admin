require 'rails_helper'

RSpec.describe PaymentJob, type: :job do
  let(:buyer) { create(:user, role: :buyer) }
  let(:seller) { create(:user, role: :seller) }
  let(:store) { create(:store, user: seller) }
  let(:order) { create(:order, buyer: buyer, store: store) }

  let(:payment_params) do
    {
      order: order,
      value: 100,
      number: '5485 4108 9516 6407',
      valid: '26/05/2025',
      cvv: '723'
    }
  end

  before do
    allow(Faraday).to receive(:new).and_return(faraday_connection)
    allow(Rails.configuration).to receive(:payment).and_return(OpenStruct.new(host: 'http://0.0.0.0:3200'))
  end

  let(:faraday_connection) do
    instance_double(Faraday::Connection, post: faraday_response)
  end

  context 'when payment is successful' do
    let(:faraday_response) do
      instance_double(Faraday::Response, success?: true)
    end

    it 'transitions order to payment_accepted' do
      PaymentJob.perform_now(**payment_params)
      order.reload
      expect(order.state).to eq 'payment_accepted'
    end
  end

  context 'when payment fails' do
    let(:faraday_response) do
      instance_double(Faraday::Response, success?: false)
    end

    it 'transitions order to payment_declined' do
      PaymentJob.perform_now(**payment_params)
      order.reload
      expect(order.state).to eq 'payment_declined'
    end
  end
end
