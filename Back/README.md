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

## Flask Application

In addition to the FastAPI backend, this project includes a Flask application (`app/main.py`) that provides the following functionality:

### Endpoints

- `POST /upload_csv` - Upload a CSV file to Google Cloud Storage
- `POST /predict_stem_personality` - Predict STEM personality based on user responses

### STEM Personality Prediction

The `/predict_stem_personality` endpoint accepts a JSON payload with user responses and returns a prediction of the user's STEM personality type (Science, Technology, Engineering, or Mathematics).

#### Request Format

```json
{
  "respuestas": {
    "ciencia": [3, 4, 5],     // Science question scores (1-5)
    "tecnologia": [4, 5, 3],  // Technology question scores (1-5)
    "ingenieria": [2, 3, 4],  // Engineering question scores (1-5)
    "matematicas": [5, 4, 3]  // Mathematics question scores (1-5)
  }
}
```

#### Response Format

```json
{
  "personalidad_stem": "T",
  "descripcion": "Technology (Tecnología)",
  "puntuaciones": {
    "ciencia": 4.0,
    "tecnologia": 4.33,
    "ingenieria": 3.0,
    "matematicas": 4.0
  },
  "detalles": {
    "S": {
      "nombre": "Science (Ciencia)",
      "puntuacion": 4.0,
      "porcentaje": 80.0
    },
    "T": {
      "nombre": "Technology (Tecnología)",
      "puntuacion": 4.33,
      "porcentaje": 86.6
    },
    "E": {
      "nombre": "Engineering (Ingeniería)",
      "puntuacion": 3.0,
      "porcentaje": 60.0
    },
    "M": {
      "nombre": "Mathematics (Matemáticas)",
      "puntuacion": 4.0,
      "porcentaje": 80.0
    }
  }
}
```

### Running the Flask Application

To run the Flask application:

```
python app/main.py
```

The Flask server will start on port 5000 and accept connections from any host.

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
