# Rails API Application

This is a Ruby on Rails API-only application built with:
- **Ruby**: 3.4.5
- **Rails**: 8.0.3
- **Database**: SQLite3
- **Server**: Puma

## Getting Started

### Prerequisites
- Ruby 3.4.5 or higher
- Rails 8.0.3 or higher
- SQLite3

### Installation

1. Navigate to the application directory:
   ```bash
   cd api_app
   ```

2. Install dependencies:
   ```bash
   bundle install
   ```

3. Create the database:
   ```bash
   rails db:create
   ```

4. Run database migrations (if any):
   ```bash
   rails db:migrate
   ```

### Running the Application

Start the Rails server:
```bash
rails server
```

The API will be available at `http://localhost:3000`

## API Endpoints

### Health Check
- **GET** `/api/v1/health`
  - Returns API status and basic information
  - Response format:
    ```json
    {
      "status": "ok",
      "message": "API is running successfully",
      "timestamp": "2024-01-01T12:00:00.000Z",
      "version": "1.0.0"
    }
    ```

### Built-in Health Check
- **GET** `/up`
  - Rails built-in health check endpoint
  - Returns 200 if the app boots successfully, 500 otherwise

## Project Structure

```
api_app/
├── app/
│   ├── controllers/
│   │   ├── api/
│   │   │   └── v1/
│   │   │       └── health_controller.rb
│   │   └── application_controller.rb
│   └── models/
│       └── application_record.rb
├── config/
│   ├── application.rb
│   ├── database.yml
│   └── routes.rb
├── db/
│   └── storage/
│       ├── development.sqlite3
│       └── test.sqlite3
└── Gemfile
```

## Configuration

The application is configured as API-only in `config/application.rb`:
```ruby
config.api_only = true
```

This means:
- No view rendering
- No asset pipeline
- Minimal middleware stack
- Optimized for API responses

## Database

The application uses SQLite3 with the following configuration:
- **Development**: `storage/development.sqlite3`
- **Test**: `storage/test.sqlite3`
- **Production**: `storage/production.sqlite3`

## Adding New API Endpoints

1. Create a new controller in `app/controllers/api/v1/`
2. Add routes in `config/routes.rb` under the `api/v1` namespace
3. Follow RESTful conventions for your endpoints

Example:
```ruby
# In config/routes.rb
namespace :api do
  namespace :v1 do
    resources :users
    resources :posts
  end
end
```

## Development

The application includes:
- **Debug gem** for debugging in development
- **Brakeman** for security analysis
- **RuboCop** for code style enforcement
- **Kamal** for deployment

Run code quality checks:
```bash
bundle exec rubocop
bundle exec brakeman
```