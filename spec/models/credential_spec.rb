require 'rails_helper'

RSpec.describe Credential, type: :model do
  describe ".create_access" do
    it "raises if the given access role is invalid" do
      expect {
        Credential.create_access(:non_existent)
    }.to raise_error "Invalid Access"
    end

    it "creates a credential for a given access role" do
      credential = Credential.create_access(:buyer)
      
      expect(credential.buyer?).to eq true
      expect(credential.key.empty?).to eq false
    end
  end
end
