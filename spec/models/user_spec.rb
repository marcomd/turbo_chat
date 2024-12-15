require 'rails_helper'

RSpec.describe User, type: :model do
  context 'validations' do
    let(:valid_attributes) do
      {
        email: 'user@rspec.com',
        password: 'password',
        password_confirmation: 'password'
      }
    end

    let(:invalid_attributes) do
      {
        email: 'username',
        password: 'password',
        password_confirmation: 'password'
      }
    end

    context 'when the attributes are valid' do
      let(:user) { User.new(valid_attributes) }

      it 'is valid with an email, password, and password_confirmation' do
        expect(user).to be_valid
      end
    end

    context 'when the attributes are invalid' do
      let(:user) { User.new(invalid_attributes) }

      it 'is invalid without a valid email' do
        expect(user).to_not be_valid
      end
    end
  end
end
