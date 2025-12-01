require 'rails_helper'

RSpec.describe "Messages API", type: :request do
    let!(:user) do
        User.create!(
            email: 'test@example.com',
            password: 'password123',
            password_confirmation: 'password123'
        )
    end

    let!(:user2) do
        User.create!(
            email: 'anothertest@example.com',
            password: 'password123',
            password_confirmation: 'password123'
        )
    end

    def sign_in(user)
        post '/users/sign_in', params: {
            user: {
                email: user.email,
                password: 'password123'
            }
        }, as: :json
    end

    it 'requires authentication to access messages' do
        get '/api/messages', as: :json
        expect(response).to have_http_status(:unauthorized)
    end

    it 'allows authenticated user to retrieve their messages' do
        sign_in(user)

        message1 = user.messages.create!(
            content: 'Hello, this is a test message.',
            recipient_number: '+1234567890'
        )
        message2 = user2.messages.create!(
            content: 'This is another test message.',
            recipient_number: '+1234567891'
        )

        get '/api/messages', as: :json

        expect(response).to have_http_status(:ok)
        messages = JSON.parse(response.body)

        expect(messages.length).to eq(1)
        expect(messages.first['content']).to eq('Hello, this is a test message.')
        expect(messages.first['recipient_number']).to eq('+1234567890')

        ids = messages.map { |m| m["_id"] }
        expect(ids).to include(message1.id.to_s)
        expect(ids).not_to include(message2.id.to_s)
    end
end