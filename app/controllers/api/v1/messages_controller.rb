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
      messages: [ user_message, bot_message ].map do |message|
        {
          timestamp: message.created_at.iso8601,
          id: message.id,
          type: message.message_type,
          content: message.content
        }
      end
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
