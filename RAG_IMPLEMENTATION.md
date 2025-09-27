# LLM RAG Implementation for Policy Chatbot

This document describes the implementation of a Retrieval-Augmented Generation (RAG) system for a policy chatbot using OpenAI's GPT models.

## Overview

The system processes a single policy document (Excel file), creates embeddings using OpenAI's text-embedding-ada-002 model, stores them in a vector database, and uses GPT-3.5-turbo to generate contextually relevant responses to user queries. The document is pre-processed and embedded during setup, so no document upload APIs are needed.

## Architecture

```
User Query → Embedding → Vector Search → Context Retrieval → LLM Response
```

### Components

1. **ExcelReaderService**: Reads and extracts content from Excel policy documents
2. **PolicyDocument**: Model for storing policy documents 
3. **DocumentEmbedding**: Model for storing text embeddings and chunks
4. **OpenaiService**: Interface to OpenAI API for embeddings and chat completion
5. **PolicyProcessingService**: Main service orchestrating the RAG workflow

## Setup

### 1. Install Dependencies

```bash
bundle install
```

### 2. Configure OpenAI API Key

Set your OpenAI API key as an environment variable:

```bash
export OPENAI_API_KEY=your_openai_api_key_here
```

Or create a `.env` file in the project root:

```
OPENAI_API_KEY=your_openai_api_key_here
OPENAI_MODEL=gpt-3.5-turbo
EMBEDDING_MODEL=text-embedding-ada-002
MAX_TOKENS=150
TEMPERATURE=0.7
```

### 3. Run Database Migrations

```bash
rails db:migrate
```

### 4. Initialize RAG System

Process the Excel policy document and create embeddings:

```bash
rails rag:setup
```

## API Endpoints

### 1. Enhanced Messages Endpoint (Primary Interface)

**POST** `/api/v1/messages`

The existing messages endpoint now uses RAG for generating responses.

**Body:**
```json
{
  "message": {
    "content": "What is the approval process for software installation?",
    "user_id": "user123"
  }
}
```

**Response:**
```json
{
  "messages": [
    {
      "timestamp": "2024-09-27T05:45:30Z",
      "id": 1,
      "type": "user",
      "content": "What is the approval process for software installation?"
    },
    {
      "timestamp": "2024-09-27T05:45:31Z",
      "id": 2,
      "type": "bot",
      "content": "For external application installation on MacBooks, the process requires: 1) Employee to request installation with application details and justification, 2) Approval from Project Owner/Team Lead/Executives, 3) Installation by individual employee with Network team assistance, 4) Confirmation email to Network team upon completion."
    }
  ]
}
```

### 2. Health Check

**GET** `/api/v1/health`

Check if the API is running.

**Response:**
```json
{
  "status": "ok",
  "message": "API is running successfully",
  "timestamp": "2024-09-27T05:45:30Z",
  "version": "1.0.0"
}
```

### 3. Get All Messages

**GET** `/api/v1/messages`

Retrieve chat history.

**Response:**
```json
{
  "messages": [
    {
      "timestamp": "2024-09-27T05:45:30Z",
      "id": 1,
      "type": "user",
      "content": "What is the approval process?"
    },
    {
      "timestamp": "2024-09-27T05:45:31Z",
      "id": 2,
      "type": "bot",
      "content": "The approval process requires..."
    }
  ]
}
```

## Technical Details

### Text Chunking

- Documents are split into 1000-character chunks with 200-character overlap
- Chunks respect sentence boundaries when possible
- Each chunk is embedded separately for fine-grained retrieval

### Embedding Storage

- Uses OpenAI's text-embedding-ada-002 model (1536 dimensions)
- Embeddings stored as JSON arrays in PostgreSQL/SQLite
- Content hash prevents duplicate embeddings

### Similarity Search

- Implements cosine similarity for vector comparison
- Returns top N most similar chunks for context
- Configurable result limit (default: 3-5 chunks)

### Response Generation

- System prompt includes relevant policy context
- Temperature set to 0.7 for balanced creativity/accuracy
- Max tokens configurable (default: 150)

## Error Handling

The system includes comprehensive error handling:

- API key validation
- Rate limiting respect
- Fallback responses for service failures
- Detailed logging for debugging

## Performance Considerations

- Embedding generation has API rate limits
- Consider caching for frequently accessed content
- Batch processing for large document sets
- Database indexing on content_hash and policy_document_id

## Usage Examples

### Quick Start

1. Set your OpenAI API key:
```bash
export OPENAI_API_KEY=your_openai_api_key_here
```

2. Initialize the RAG system:
```bash
rails rag:setup
```

3. Start the Rails server:
```bash
rails server
```

4. Test the chatbot:
```bash
curl -X POST http://localhost:3000/api/v1/messages \
  -H "Content-Type: application/json" \
  -d '{"message": {"content": "What is the approval process for software installation?", "user_id": "test_user"}}'
```

### RAG System Management

Check system status:
```bash
rails rag:status
```

Test with a sample query:
```bash
rails rag:test["How do I get approval for installing software?"]
```

Reinitialize if needed:
```bash
rails rag:setup
```

## Monitoring and Debugging

- Check Rails logs for OpenAI API errors
- Monitor token usage for cost optimization
- Track embedding creation success rates
- Review similarity scores for relevance tuning

## Future Enhancements

- Support for multiple file formats (PDF, Word, etc.)
- Advanced chunking strategies (semantic segmentation)
- Hybrid search (keyword + semantic)
- Fine-tuning for domain-specific terminology
- Real-time document updates
- User feedback integration for relevance improvement
