require "json"

class DocumentEmbedding < ApplicationRecord
  belongs_to :policy_document

  validates :content_hash, presence: true
  validates :embedding, presence: true
  validates :chunk_text, presence: true
  validates :chunk_index, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def embedding_vector
    @embedding_vector ||= JSON.parse(embedding)
  end

  def embedding_vector=(vector)
    self.embedding = vector.to_json
    @embedding_vector = vector
  end

  def similarity_to(other_vector)
    return 0.0 unless other_vector.is_a?(Array) && embedding_vector.is_a?(Array)
    return 0.0 if other_vector.length != embedding_vector.length

    # Calculate cosine similarity
    dot_product = embedding_vector.zip(other_vector).map { |a, b| a * b }.sum
    magnitude_a = Math.sqrt(embedding_vector.map { |a| a * a }.sum)
    magnitude_b = Math.sqrt(other_vector.map { |a| a * a }.sum)

    return 0.0 if magnitude_a == 0.0 || magnitude_b == 0.0

    dot_product / (magnitude_a * magnitude_b)
  end

  def self.search_similar(query_vector, limit = 5)
    all.map do |embedding|
      {
        embedding: embedding,
        similarity: embedding.similarity_to(query_vector)
      }
    end.sort_by { |result| -result[:similarity] }
      .first(limit)
      .map { |result| result[:embedding] }
  end

  def content_preview(length = 100)
    chunk_text.length > length ? "#{chunk_text[0..length]}..." : chunk_text
  end
end
