class DocumentChunk < ApplicationRecord
  validates :content, presence: true
  validates :embedding, presence: true
  validates :source, presence: true
end
