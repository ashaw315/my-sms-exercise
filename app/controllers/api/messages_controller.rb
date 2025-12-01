class Api::MessagesController < ApplicationController
    before_action :authenticate_user!

    def index
        @messages = current_user.messages.order(created_at: :desc)
        render json: @messages
    end

    def create
        @messages = current_user.messages.new(message_params)
        if @messages.save
            render json: @messages, status: :created
        else
            render json: { errors: @messages.errors.full_messages }, status: :unprocessable_content
        end
    end

    private

    def message_params
        params.require(:message).permit(:content, :recipient_number)
    end
end
