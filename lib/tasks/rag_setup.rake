namespace :rag do
  desc "Initialize RAG system with policy document embeddings"
  task setup: :environment do
    puts "🤖 Setting up RAG system with policy embeddings..."

    begin
      # Clear existing data
      puts "📝 Clearing existing embeddings..."
      DocumentEmbedding.destroy_all
      PolicyDocument.destroy_all

      # Process the Excel file
      puts "📊 Processing Excel policy document..."
      policy_service = PolicyProcessingService.new
      policy_service.process_excel_file

      # Summary
      documents_count = PolicyDocument.count
      embeddings_count = DocumentEmbedding.count

      puts "✅ RAG setup completed successfully!"
      puts "   📄 Documents processed: #{documents_count}"
      puts "   🔍 Embeddings created: #{embeddings_count}"
      puts ""
      puts "💡 Your chatbot is now ready to answer policy questions!"
      puts "   Test it using: POST /api/v1/messages"

    rescue => e
      puts "❌ Error setting up RAG system: #{e.message}"
      puts "   Make sure your OPENAI_API_KEY environment variable is set."
      puts "   Example: export OPENAI_API_KEY=your_key_here"
      exit 1
    end
  end

  desc "Check RAG system status"
  task status: :environment do
    puts "🔍 RAG System Status:"
    puts "   📄 Policy Documents: #{PolicyDocument.count}"
    puts "   🔍 Document Embeddings: #{DocumentEmbedding.count}"

    if PolicyDocument.exists?
      policy = PolicyDocument.first
      puts "   📊 Policy: #{policy.title}"
      puts "   📝 Content length: #{policy.content.length} characters"
      puts "   📅 Last updated: #{policy.updated_at}"
    end

    puts "   🤖 OpenAI API key: #{ENV['OPENAI_API_KEY'] ? 'Set ✅' : 'Not set ❌'}"
  end

  desc "Test RAG system with a sample query"
  task :test, [ :query ] => :environment do |t, args|
    query = args[:query] || "How do I install a new application?"

    puts "🧪 Testing RAG system..."
    puts "   Query: #{query}"
    puts ""

    begin
      policy_service = PolicyProcessingService.new
      response = policy_service.generate_rag_response(query)

      puts "🤖 Response:"
      puts "   #{response}"
      puts ""
      puts "✅ Test completed successfully!"

    rescue => e
      puts "❌ Test failed: #{e.message}"
      puts "   Run 'rails rag:setup' first to initialize the system."
    end
  end
end

# Add setup instructions
task :setup_instructions do
  puts ""
  puts "🚀 Quick Setup Guide:"
  puts "1. Set your OpenAI API key: export OPENAI_API_KEY=your_key_here"
  puts "2. Run: rails rag:setup"
  puts "3. Test: rails rag:test"
  puts "4. Start server: rails server"
  puts "5. Send messages to: POST http://localhost:3000/api/v1/messages"
  puts ""
end
