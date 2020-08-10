require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do

  let(:user) { FactoryBot.create(:user)}
  let(:user1) { FactoryBot.create(:user)}
  let(:master) { FactoryBot.create(:user,:master)}
  let(:message) { FactoryBot.create(:message,to: user.id,from: user1.id)}
  let(:message1) { FactoryBot.create(:message,to: user1.id,from: user.id)}

  describe '#users' do
    # before do
    # end

    before :each do
      request.env["HTTP_ACCEPT"] = 'application/json'
    end

    it 'should be unauthorized when token missing' do
      get :index#, params: {token: master.token}
      expect(response).to have_http_status(:unauthorized)
    end

    it 'should be unauthorized when permission dont match to permission param' do
      get :index, params: {token: user.token, permission: 'master'}
      expect(response).to have_http_status(:unauthorized)
    end

    it 'should be return only normal type users' do
      get :index, params: {token: user.token}
      expect(response).to have_http_status(:success)
      JSON.parse(response.body).each { |user|
        expect(user['permission']).to eq('normal')
      }
    end

  end

  describe '#update' do
    before :each do
      request.env["HTTP_ACCEPT"] = 'application/json'
    end

    it 'should be update user' do
      patch :update, params: {id: user.id, token: user.token, user: user.attributes}
      expect(response).to be_success
    end
  end

  describe '#messages' do
    before :each do
      request.env["HTTP_ACCEPT"] = 'application/json'
    end

    it "is valid with valid attributes" do
      expect(message).to be_valid
    end

    it 'should be register messages to user' do
      message.reload
      message1.reload

      get :messages, params: {id: user.id, token: user.token}

      Rails.logger.info "messages #{response.body}"

      expect(JSON.parse(response.body).length).to eq(2)
      expect(response).to have_http_status(:success)
    end
  end
end
