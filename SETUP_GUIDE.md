# RAG Chatbot Setup Guide

## Quick Start (3 Steps)

### 1. Set OpenAI API Key
```bash
export OPENAI_API_KEY=your_openai_api_key_here
```

### 2. Initialize RAG System
```bash
rails rag:setup
```

### 3. Start the Server
```bash
rails server
```

## Test Your Chatbot

### Using curl:
```bash
curl -X POST http://localhost:3000/api/v1/messages \
  -H 'Content-Type: application/json' \
  -d '{"message": {"content": "How do I install software on my MacBook?", "user_id": "user123"}}'
```

### Example Response:
```json
{
  "messages": [
    {
      "timestamp": "2024-09-27T05:45:30Z",
      "id": 1,
      "type": "user",
      "content": "How do I install software on my MacBook?"
    },
    {
      "timestamp": "2024-09-27T05:45:31Z",
      "id": 2,
      "type": "bot",
      "content": "To install external applications on MacBooks, you need to follow the approval process: 1) Individual employee requests installation mentioning the application and reason, 2) Get approval from Project Owner/Team Lead/Executives, 3) Install with help of Network team, 4) Send confirmation to Network team once installed."
    }
  ]
}
```

## RAG System Management

### Check System Status
```bash
rails rag:status
```

### Test with Sample Query
```bash
rails rag:test["Who approves software installations?"]
```

### Reinitialize if Needed
```bash
rails rag:setup
```

## Available Endpoints

- `POST /api/v1/messages` - Send message to chatbot
- `GET /api/v1/messages` - Get chat history  
- `GET /api/v1/health` - Health check

## How It Works

1. **Document Processing**: The Excel policy document is automatically processed and chunked into smaller sections
2. **Embedding Creation**: Each chunk is converted to vector embeddings using OpenAI's text-embedding-ada-002
3. **Query Processing**: User questions are embedded and matched against stored chunks using cosine similarity
4. **Response Generation**: Relevant chunks are sent to GPT-3.5-turbo along with the user question to generate contextual responses

## Features

- ✅ Pre-embedded policy knowledge base
- ✅ Intelligent context retrieval 
- ✅ Natural language responses
- ✅ Chat history storage
- ✅ Simple REST API
- ✅ Easy setup and maintenance

## Architecture

```
Excel Policy Document → Text Chunks → Embeddings → Vector Database
                                                         ↓
User Question → Embedding → Similarity Search → Context → GPT Response
```

## Troubleshooting

### "OpenAI API key not set"
Make sure to export your API key:
```bash
export OPENAI_API_KEY=sk-your-key-here
```

### "No embeddings found"  
Run the setup command:
```bash
rails rag:setup
```

### Test locally without API key
```bash
ruby test_rag_local.rb
```

## Cost Optimization

- Embeddings are created once during setup (not per query)
- Responses are limited to 150 tokens by default
- Only 3-5 most relevant chunks are used per query
- No unnecessary API calls after initial setup

## Next Steps

1. Customize the system prompt in `OpenaiService`
2. Adjust chunk size and overlap in `PolicyDocument#chunk_content`
3. Modify response length and temperature in `OpenaiService`
4. Add more policy documents by updating `PolicyProcessingService`
