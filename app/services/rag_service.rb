class RagService
  def initialize
    @openai_client = OpenAI::Client.new(api_key: ENV["OPENAI_API_KEY"])
  end

  def generate_response(user_message)
    puts "🔍 Searching for relevant information..."

    # Try multiple search strategies
    relevant_chunks = find_relevant_chunks_enhanced(user_message)

    if relevant_chunks.any?
      puts "✅ Found #{relevant_chunks.length} relevant chunks"
      generate_contextual_response(user_message, relevant_chunks)
    else
      puts "❌ No relevant information found"
      "Sorry, I don't have information about that topic. Please try asking about something else."
    end
  end

  private

  def find_relevant_chunks_enhanced(user_message, limit: 3)
    # Strategy 1: Original embedding similarity
    embedding_chunks = find_relevant_chunks(user_message, limit: limit)

    # Strategy 2: Query expansion for generic questions
    expanded_chunks = find_chunks_by_expanded_query(user_message)

    # Combine and deduplicate results
    all_chunks = (embedding_chunks + expanded_chunks).uniq

    # Score and rank all chunks
    scored_chunks = score_and_rank_chunks(user_message, all_chunks)

    # Return top chunks
    scored_chunks.first(limit).map { |item| item[:chunk] }
  end

  def find_relevant_chunks(user_message, limit: 3)
    user_embedding = generate_embedding(user_message)

    # Calculate cosine similarity with all chunks
    similarities = DocumentChunk.all.map do |chunk|
      similarity = cosine_similarity(user_embedding, JSON.parse(chunk.embedding))
      { chunk: chunk, similarity: similarity }
    end

    # Return top similar chunks
    similarities
      .sort_by { |item| -item[:similarity] }
      .first(limit)
      .map { |item| item[:chunk] }
  end

  def generate_contextual_response(user_message, relevant_chunks)
    context = relevant_chunks.map(&:content).join("\n\n")

    response = @openai_client.chat.completions.create(
      model: "gpt-3.5-turbo",
      messages: [
        {
          role: "system",
          content: "You are Leo, a friendly and professional internal company processes expert."\
          "You have the following information from our knowledge base to help answer the query:\n#{context}\n\n"\
          "Use the context information to provide a comprehensive and helpful response. You can give definitive answers based on the available information.\n"\
          "Be confident and direct when you have relevant information. If the context contains the answer, provide it clearly without being overly cautious.\n"\
          "IMPORTANT: When the context contains a list (like holidays, policies, etc.), use it to give definitive answers. If something is not in the list, say it's not there - don't be overly cautious.\n"\
          "Please keep these guidelines in mind:\n"\
          "Logic:\n"\
          "- If the user's query is not related to company processes, do not answer it. Instead, redirect the conversation gently.\n"\
          "- If you have relevant information in the context, provide a clear and direct answer.\n"\
          "- If the information is not available in the context, respond with \"Sorry, I don't have information about this. Can I help you with anything else?\"\n"\
          "Tone:\n"\
          "- Speak warmly and professionally. For example: \"I'm sorry, I couldn't find the answer to that. However, I'm here to help!\"\n"\
          "- Ensure the user feels heard and understood, even if the solution isn't immediately available.\n"\
          "Content & Format:\n"\
          "- Do not make up answers.\n"\
          "- Give direct, concise, and clear responses.\n"\
          "- Answer only the user's question without unnecessary information.\n"\
          "- If multiple solutions are available, prioritize by relevance.\n"
        },
        {
          role: "user",
          content: "Context: #{context}\n\nQuestion: #{user_message}"
        }
      ],
      max_tokens: 500
    )

    response.choices.first.message.content
  end

  def generate_embedding(text)
    response = @openai_client.embeddings.create(
      model: "text-embedding-3-small",
      input: text
    )
    response.data.first.embedding
  end

  def cosine_similarity(vec_a, vec_b)
    dot_product = vec_a.zip(vec_b).sum { |a, b| a * b }
    magnitude_a = Math.sqrt(vec_a.sum { |x| x**2 })
    magnitude_b = Math.sqrt(vec_b.sum { |x| x**2 })

    dot_product / (magnitude_a * magnitude_b)
  end


  def find_chunks_by_expanded_query(user_message)
    # Expand generic queries to more specific terms
    expanded_terms = expand_query(user_message)
    return [] if expanded_terms.empty?

    # Find chunks containing expanded terms
    DocumentChunk.all.select do |chunk|
      expanded_terms.any? { |term| chunk.content.downcase.include?(term.downcase) }
    end
  end


  def expand_query(user_message)
    # Map generic questions to more specific terms
    expansions = {
      "what" => [ "definition", "meaning", "explanation", "description" ],
      "how" => [ "process", "method", "steps", "procedure" ],
      "when" => [ "timing", "schedule", "deadline", "period" ],
      "where" => [ "location", "place", "position" ],
      "why" => [ "reason", "purpose", "cause", "rationale" ]
    }

    expanded_terms = []
    user_message.downcase.split.each do |word|
      if expansions[word]
        expanded_terms.concat(expansions[word])
      end
    end

    expanded_terms.uniq
  end

  def score_and_rank_chunks(user_message, chunks)
    user_embedding = generate_embedding(user_message)

    chunks.map do |chunk|
      # Calculate embedding similarity
      embedding_score = cosine_similarity(user_embedding, JSON.parse(chunk.embedding))

      # Calculate text similarity score
      text_similarity = calculate_text_similarity(user_message, chunk.content)

      # Combined score (weighted)
      combined_score = (embedding_score * 0.7) + (text_similarity * 0.3)

      { chunk: chunk, score: combined_score }
    end.sort_by { |item| -item[:score] }
  end

  def calculate_text_similarity(query, content)
    # Simple text similarity based on common words
    query_words = query.downcase.split(/\W+/)
    content_words = content.downcase.split(/\W+/)

    common_words = query_words & content_words
    return 0 if query_words.empty?

    common_words.length.to_f / query_words.length
  end
end
