class DocumentProcessor
  def initialize
    @openai_client = OpenAI::Client.new(api_key: ENV["OPENAI_API_KEY"])
  end

  def process_document(file_path)
    puts "📖 Extracting content from #{File.basename(file_path)}"
    content = extract_content(file_path)

    puts "✂️  Chunking text (#{content.length} characters)"
    chunks = chunk_text(content)

    puts "🧠 Generating embeddings for #{chunks.length} chunks"
    embeddings = generate_embeddings(chunks)

    puts "💾 Storing chunks and embeddings"
    store_embeddings(chunks, embeddings, file_path)

    {
      chunks_count: chunks.length,
      embeddings_count: embeddings.length,
      source: File.basename(file_path)
    }
  end

  private

  def extract_content(file_path)
    case File.extname(file_path).downcase
    when ".pdf"
      extract_pdf_content(file_path)
    when ".docx"
      extract_docx_content(file_path)
    when ".txt"
      File.read(file_path)
    when ".csv"
      extract_csv_content(file_path)
    else
      raise "Unsupported file type: #{File.extname(file_path)}"
    end
  end

  def extract_pdf_content(file_path)
    require "pdf-reader"
    reader = PDF::Reader.new(file_path)
    reader.pages.map(&:text).join("\n")
  end

  def extract_docx_content(file_path)
    require "docx"
    doc = Docx::Document.open(file_path)
    doc.paragraphs.map(&:text).join("\n")
  end

  def extract_csv_content(file_path)
    require "csv"

    content_parts = []

    CSV.foreach(file_path, headers: true) do |row|
      # Convert each row to a readable format
      row_data = row.to_h

      # Create a text representation of the row
      row_text = row_data.map { |key, value| "#{key}: #{value}" }.join(" | ")
      content_parts << row_text
    end

    # Join all rows with newlines
    content_parts.join("\n")
  end

  def chunk_text(text, chunk_size: 1000, overlap: 200)
    words = text.split
    chunks = []

    (0...words.length).step(chunk_size - overlap) do |i|
      chunk = words[i, chunk_size].join(" ")
      chunks << chunk if chunk.length > 50
    end

    chunks
  end

  def generate_embeddings(chunks)
    chunks.map.with_index do |chunk, index|
      print "  Generating embedding #{index + 1}/#{chunks.length}...\r"

      response = @openai_client.embeddings.create(
        model: "text-embedding-3-small",
        input: chunk
      )

      response.data.first.embedding
    end
  end

  def store_embeddings(chunks, embeddings, file_path)
    chunks.zip(embeddings).each do |chunk, embedding|
      DocumentChunk.create!(
        content: chunk,
        embedding: embedding.to_json,
        source: File.basename(file_path)
      )
    end
  end
end
