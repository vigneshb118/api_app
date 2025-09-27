require "openai"

class OpenaiService
  EMBEDDING_MODEL = "text-embedding-ada-002"
  CHAT_MODEL = "gpt-3.5-turbo"

  def initialize
    @client = OpenAI::Client.new
  end

  def generate_embedding(text)
    response = @client.embeddings(
      parameters: {
        model: EMBEDDING_MODEL,
        input: text
      }
    )

    if response["data"] && response["data"].first
      response["data"].first["embedding"]
    else
      raise "Failed to generate embedding: #{response}"
    end
  rescue => e
    Rails.logger.error "OpenAI Embedding Error: #{e.message}"
    raise e
  end

  def generate_chat_response(query, context_chunks, max_tokens: 150, temperature: 0.7)
    system_prompt = build_system_prompt(context_chunks)

    response = @client.chat(
      parameters: {
        model: CHAT_MODEL,
        messages: [
          { role: "system", content: system_prompt },
          { role: "user", content: query }
        ],
        max_tokens: max_tokens,
        temperature: temperature
      }
    )

    if response.dig("choices", 0, "message", "content")
      response["choices"][0]["message"]["content"].strip
    else
      raise "Failed to generate chat response: #{response}"
    end
  rescue => e
    Rails.logger.error "OpenAI Chat Error: #{e.message}"
    raise e
  end

  private

  def build_system_prompt(context_chunks)
    context_text = context_chunks.map do |chunk|
      "--- Document Section ---\n#{chunk.chunk_text}\n"
    end.join("\n")

    <<~PROMPT
      You are a helpful assistant that answers questions about company policies and procedures based on the provided context.

      Use the following context to answer questions accurately and helpfully:

      #{context_text}

      Instructions:
      - Only answer based on the provided context
      - If the answer isn't in the context, say "I don't have enough information to answer that question based on the available policies."
      - Be specific and cite relevant policy sections when possible
      - Keep responses concise but informative
      - If the question is about approval processes, include who needs to approve and any specific steps mentioned
    PROMPT
  end
end
