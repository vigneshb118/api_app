class Message < ApplicationRecord
  validates :content, presence: true
  validates :message_type, presence: true, inclusion: { in: %w[user bot] }

  scope :user_messages, -> { where(message_type: "user") }
  scope :bot_messages, -> { where(message_type: "bot") }
end
