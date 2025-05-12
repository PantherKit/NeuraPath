# FastAPI CRUD Template

A scalable and ready-to-use FastAPI template for building CRUD backends with user authentication.

## Features

- **Complete JWT Authentication**: User login, role-based access control
- **User Management**: Create, read, update, and delete users
- **Item Management**: Full CRUD operations for items with owner relationships
- **Database Integration**: SQLAlchemy ORM with support for SQLite or any other SQL database
- **API Documentation**: Automatic Swagger/OpenAPI documentation

## Project Structure

```
├── app/
│   ├── core/            # Core functionality (security, dependencies)
│   ├── models/          # SQLAlchemy database models
│   ├── routes/          # API endpoints/routes
│   ├── schemas/         # Pydantic models/schemas
│   ├── database.py      # Database configuration
├── main.py              # Application entry point
├── create_admin.py      # Helper script to create admin user
├── requirements.txt     # Project dependencies
├── .env-example         # Example environment variables
```

## Getting Started

1. Clone the repository
2. Install dependencies:
   ```
   pip install -r requirements.txt
   ```
3. Copy `.env-example` to `.env` and update the values:
   ```
   cp .env-example .env
   ```
4. Create an admin user:
   ```
   python create_admin.py --email admin@example.com --username admin --password securepassword
   ```
5. Run the application:
   ```
   python main.py
   ```
6. Access the API documentation at http://localhost:8000/docs

## Environment Variables

The following environment variables can be configured in your `.env` file:

```
# Database settings
DATABASE_URL=sqlite:///./app.db

# Security
SECRET_KEY=your-secret-key-change-this-in-production
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# Server
HOST=0.0.0.0
PORT=8000
RELOAD=true
```

## API Endpoints

### Authentication
- `POST /api/login` - Get access token

### Users
- `GET /api/users/` - List all users (admin only)
- `POST /api/users/` - Create a new user (admin only)
- `GET /api/users/me` - Get current user info
- `PUT /api/users/me` - Update current user
- `GET /api/users/{user_id}` - Get user by ID
- `PUT /api/users/{user_id}` - Update user (admin only)
- `DELETE /api/users/{user_id}` - Delete user (admin only)

### Items
- `GET /api/items/` - List items (filtered by ownership)
- `POST /api/items/` - Create a new item
- `GET /api/items/{item_id}` - Get item by ID
- `PUT /api/items/{item_id}` - Update item
- `DELETE /api/items/{item_id}` - Delete item

## How to Use This Template

### Adding New Models

1. Create a model in `app/models/`
2. Create corresponding schemas in `app/schemas/`
3. Create routes in `app/routes/`
4. Include the router in `main.py`

## Extending the Template

This template provides a solid foundation for building CRUD backends. You can extend it by:

- Adding additional models and relationships
- Implementing more complex validation
- Adding background tasks with Celery
- Integrating with external services
- Adding caching mechanisms

## License

MIT 