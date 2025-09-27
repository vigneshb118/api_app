namespace :documents do
  desc "Process a document file and generate embeddings"
  task :process, [ :file_path ] => :environment do |t, args|
    if args[:file_path].nil?
      puts "Usage: rails documents:process[path/to/document.pdf]"
      exit 1
    end

    file_path = args[:file_path]

    unless File.exist?(file_path)
      puts "Error: File '#{file_path}' not found"
      exit 1
    end

    puts "Processing document: #{file_path}"

    processor = DocumentProcessor.new
    result = processor.process_document(file_path)

    puts "✅ Document processed successfully!"
    puts "📄 Chunks created: #{result[:chunks_count]}"
    puts "🔢 Embeddings generated: #{result[:embeddings_count]}"
  end

  desc "Process all documents in a directory"
  task :process_directory, [ :directory_path ] => :environment do |t, args|
    if args[:directory_path].nil?
      puts "Usage: rails documents:process_directory[path/to/documents/]"
      exit 1
    end

    directory_path = args[:directory_path]

    unless Dir.exist?(directory_path)
      puts "Error: Directory '#{directory_path}' not found"
      exit 1
    end

    puts "Processing all documents in: #{directory_path}"

    processor = DocumentProcessor.new
    total_chunks = 0

    Dir.glob("#{directory_path}/**/*.{pdf,txt,docx,csv}").each do |file_path|
      puts "\n📄 Processing: #{File.basename(file_path)}"
      result = processor.process_document(file_path)
      total_chunks += result[:chunks_count]
    end

    puts "\n✅ All documents processed successfully!"
    puts "📄 Total chunks created: #{total_chunks}"
  end

  desc "Clear all document chunks and embeddings"
  task clear: :environment do
    count = DocumentChunk.count
    DocumentChunk.destroy_all
    puts "🗑️  Cleared #{count} document chunks"
  end

  desc "Show statistics about processed documents"
  task stats: :environment do
    total_chunks = DocumentChunk.count
    sources = DocumentChunk.distinct.pluck(:source)

    puts "📊 Document Processing Statistics:"
    puts "📄 Total chunks: #{total_chunks}"
    puts "📁 Sources: #{sources.join(', ')}"

    if total_chunks > 0
      puts "📏 Average chunk length: #{DocumentChunk.average('LENGTH(content)').to_i} characters"
    end
  end
end
