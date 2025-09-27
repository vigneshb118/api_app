class Api::V1::MessagesController < ApplicationController
  def index
    messages = Message.order(:created_at).all
    render json: format_messages_response(messages)
  end

  def create
    Message.create!(
      content: message_params[:content],
      message_type: "user",
      user_id: message_params[:user_id]
    )

    rag_service = RagService.new
    bot_response = rag_service.generate_response(message_params[:content])
    bot_message = Message.create!(
      content: bot_response,
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
    responses = [
      "That's an interesting question! Let me think about that.",
      "I understand what you're asking. Here's what I think...",
      "Thanks for sharing that with me. Here's my response:",
      "I see what you mean. Let me help you with that.",
      "That's a great point! Here's what I would suggest:"
    ]

    responses.sample + " You said: '#{user_content}'"
  end
end
