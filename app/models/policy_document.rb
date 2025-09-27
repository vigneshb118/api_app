class PolicyDocument < ApplicationRecord
  has_many :document_embeddings, dependent: :destroy

  validates :title, presence: true
  validates :content, presence: true

  scope :by_source_file, ->(file) { where(source_file: file) }
  scope :by_sheet, ->(sheet) { where(sheet_name: sheet) }

  def content_preview(length = 200)
    content.length > length ? "#{content[0..length]}..." : content
  end

  def chunk_content(chunk_size = 1000, overlap = 200)
    chunks = []
    content_length = content.length

    i = 0
    chunk_index = 0

    while i < content_length
      end_pos = [i + chunk_size, content_length].min

      # Try to find a good break point (end of sentence or paragraph)
      if end_pos < content_length
        last_period = content.rindex(/[.!?]\s/, end_pos)
        last_newline = content.rindex(/\n/, end_pos)

        break_point = [last_period, last_newline].compact.max
        end_pos = break_point + 1 if break_point && break_point > i + chunk_size / 2
      end

      chunk_text = content[i...end_pos].strip
      next if chunk_text.empty?

      chunks << {
        text: chunk_text,
        index: chunk_index,
        start: i,
        end: end_pos
      }

      chunk_index += 1
      i = end_pos - overlap
      i = [i, end_pos].max # Ensure we always move forward
    end

    chunks
  end
end
