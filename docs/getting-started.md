# Home Board - Quick Start Guide

## Getting Started with Docker

This is the easiest way to get the backend running locally.

### Prerequisites
- Docker Desktop installed and running
- Git

### Steps

1. **Clone the repository** (if not already done):
   ```bash
   git clone <repository-url>
   cd home-board
   ```

2. **Start the services**:
   ```bash
   cd docker
   docker-compose up -d
   ```

3. **Wait for services to start**:
   The database needs to initialize and the API will run migrations automatically.
   Wait about 30 seconds for everything to be ready.

4. **Access the API**:
   - API Swagger UI: http://localhost:8080
   - Database: localhost:5432

5. **Login with default credentials**:
   - Username: `admin`
   - Password: `Admin123!`

### Verify Everything Works

1. Open http://localhost:8080 in your browser
2. Click "Authorize" button in Swagger UI
3. Click "Try it out" on `/api/auth/login`
4. Enter credentials and execute
5. Copy the `accessToken` from the response
6. Click "Authorize" again and paste: `Bearer <your-token>`
7. Try other endpoints!

### Stop the Services

```bash
docker-compose down
```

To also remove the database volume:
```bash
docker-compose down -v
```

## Development without Docker

### Prerequisites
- .NET 8 SDK
- PostgreSQL installed locally

### Steps

1. **Start PostgreSQL** (if not running)

2. **Update connection string** in `backend/src/HomeBoard.Api/appsettings.json`:
   ```json
   "ConnectionStrings": {
     "Default": "Host=localhost;Port=5432;Database=homeboard;Username=postgres;Password=yourpassword"
   }
   ```

3. **Run migrations**:
   ```bash
   cd backend/src/HomeBoard.Api
   dotnet ef database update
   ```

4. **Run the API**:
   ```bash
   dotnet run
   ```

5. **Access the API** at http://localhost:5000

## Common Tasks

### Create a New User (Kid)

1. Login as admin
2. POST to `/api/users`:
   ```json
   {
     "username": "johnny",
     "displayName": "Johnny",
     "password": "Kid123!",
     "role": 1
   }
   ```

### Create a Task

1. POST to `/api/tasks/definitions`:
   ```json
   {
     "title": "Make Bed",
     "description": "Make your bed every morning",
     "defaultPoints": 5
   }
   ```

2. POST to `/api/tasks/assignments`:
   ```json
   {
     "taskDefinitionId": "<uuid-from-previous-step>",
     "assignedToUserId": "<johnny-user-id>",
     "scheduleType": 0,
     "daysOfWeek": 127,
     "dueTime": "09:00:00"
   }
   ```

### Complete a Task (as Kid)

1. Login as the kid user
2. GET `/api/me/today` to see today's tasks
3. POST to `/api/tasks/{assignmentId}/complete`

### Verify Task (as Admin)

1. Login as admin
2. GET `/api/verification/pending`
3. POST to `/api/verification/{completionId}/verify` with optional points:
   ```json
   {
     "pointsAwarded": 10
   }
   ```

## Troubleshooting

### Database connection failed
- Ensure PostgreSQL is running
- Check connection string in appsettings.json
- Verify database credentials

### Migration errors
```bash
cd backend/src/HomeBoard.Api
dotnet ef database drop
dotnet ef database update
```

### Port already in use
Change ports in docker-compose.yml:
```yaml
ports:
  - "8081:8080"  # Change 8081 to any available port
```

### Docker services won't start
```bash
docker-compose down -v
docker-compose up -d --force-recreate
```

## Next Steps

- Read [Architecture Documentation](architecture.md)
- Read [API Documentation](api.md)
- Start building the Flutter frontend
- Explore the code structure

## Need Help?

Check the logs:
```bash
# API logs
docker logs homeboard-api

# Database logs
docker logs homeboard-db
```
