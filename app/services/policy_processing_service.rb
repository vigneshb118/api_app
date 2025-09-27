require "digest"

class PolicyProcessingService
  def initialize
    @openai_service = OpenaiService.new
    @excel_reader = ExcelReaderService.new("Endorsement Process Excel.xlsx")
  end

  def process_excel_file
    text_content = @excel_reader.extract_text_content

    text_content.each do |sheet_data|
      process_sheet_content(sheet_data)
    end
  end

  def process_sheet_content(sheet_data)
    # Create or find the policy document
    policy_doc = PolicyDocument.find_or_create_by(
      source_file: "Endorsement Process Excel.xlsx",
      sheet_name: sheet_data[:sheet_name]
    ) do |doc|
      doc.title = "IAE Process - #{sheet_data[:sheet_name]}"
      doc.content = sheet_data[:content]
      doc.metadata = {
        processed_at: Time.current,
        total_length: sheet_data[:content].length
      }
    end

    # Update content if it has changed
    if policy_doc.content != sheet_data[:content]
      policy_doc.update!(
        content: sheet_data[:content],
        metadata: policy_doc.metadata.merge(
          updated_at: Time.current,
          total_length: sheet_data[:content].length
        )
      )
      # Clear existing embeddings as content has changed
      policy_doc.document_embeddings.destroy_all
    end

    # Process chunks and create embeddings if they don't exist
    if policy_doc.document_embeddings.empty?
      create_embeddings_for_document(policy_doc)
    end

    policy_doc
  end

  def create_embeddings_for_document(policy_doc)
    chunks = policy_doc.chunk_content(1000, 200)

    chunks.each do |chunk|
      content_hash = Digest::SHA256.hexdigest(chunk[:text])

      # Skip if embedding already exists for this content
      next if DocumentEmbedding.exists?(
        policy_document: policy_doc,
        content_hash: content_hash
      )

      begin
        embedding_vector = @openai_service.generate_embedding(chunk[:text])

        DocumentEmbedding.create!(
          policy_document: policy_doc,
          content_hash: content_hash,
          embedding_vector: embedding_vector,
          chunk_text: chunk[:text],
          chunk_index: chunk[:index]
        )

        Rails.logger.info "Created embedding for chunk #{chunk[:index]} of document #{policy_doc.id}"

        # Add a small delay to respect API rate limits
        sleep(0.1)

      rescue => e
        Rails.logger.error "Failed to create embedding for chunk #{chunk[:index]}: #{e.message}"
        # Continue with other chunks even if one fails
      end
    end
  end

  def search_relevant_context(query, limit = 3)
    begin
      query_embedding = @openai_service.generate_embedding(query)
      DocumentEmbedding.search_similar(query_embedding, limit)
    rescue => e
      Rails.logger.error "Failed to search context: #{e.message}"
      []
    end
  end

  def generate_rag_response(query)
    # Get relevant context
    context_chunks = search_relevant_context(query, 3)

    if context_chunks.empty?
      return "I don't have enough information to answer that question based on the available policies."
    end

    # Generate response using OpenAI
    begin
      @openai_service.generate_chat_response(query, context_chunks)
    rescue => e
      Rails.logger.error "Failed to generate RAG response: #{e.message}"
      "I apologize, but I'm having trouble processing your question right now. Please try again later."
    end
  end
end
