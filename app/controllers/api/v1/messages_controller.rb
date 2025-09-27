class Api::V1::MessagesController < ApplicationController
  def index
    messages = Message.order(:created_at).all
    render json: format_messages_response(messages)
  end

  def create
    user_message = Message.create!(
      content: message_params[:content],
      message_type: "user",
      user_id: message_params[:user_id]
    )

    bot_message = Message.create!(
      content: generate_bot_response(message_params[:content]),
      message_type: "bot",
      user_id: nil
    )

    render json: {
      timestamp: bot_message.created_at.iso8601,
      id: bot_message.id,
      type: bot_message.message_type,
      content: bot_message.content
    }
  end

  private

  def format_messages_response(messages)
    {
      messages: messages.map do |message|
        {
            timestamp: message.created_at.iso8601,
            id: message.id,
            type: message.message_type,
            content: message.content
        }
      end
    }
  end

  def message_params
    params.require(:message).permit(:content, :user_id)
  end

  def generate_bot_response(user_content)
    begin
      policy_service = PolicyProcessingService.new
      policy_service.generate_rag_response(user_content)
    rescue => e
      Rails.logger.error "RAG Response Error: #{e.message}"

      # Fallback response
      "I apologize, but I'm having trouble accessing the policy information right now. Please ensure your OpenAI API key is configured and try again."
    end
  end
end
