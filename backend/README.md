# Home Board - Backend README

## Overview

Home Board is a tablet-first web application for families to manage chores and rewards for kids. This is the backend API built with ASP.NET Core Web API (.NET 8).

## Tech Stack

- **Framework**: ASP.NET Core Web API (.NET 10)
- **Database**: PostgreSQL with Entity Framework Core
- **Authentication**: JWT with role-based authorization
- **API Documentation**: Swagger/OpenAPI

## Architecture

The project follows clean architecture principles with three main layers:

### HomeBoard.Domain
Contains all domain entities and enums:
- **Entities**: User, TaskDefinition, TaskAssignment, TaskCompletion, PointsLedger, Reward, RewardRedemption, FamilySettings
- **Enums**: UserRole, ScheduleType, TaskStatus, PointSourceType, RedemptionStatus, DayOfWeekFlag

### HomeBoard.Infrastructure
Contains data access layer:
- **HomeBoardDbContext**: EF Core database context
- **DbSeeder**: Seeds default admin user and settings
- **Migrations**: Database migrations (generated via EF Core CLI)

### HomeBoard.Api
Contains API controllers, services, and models:
- **Controllers**: Auth, Users, Tasks, Me, Verification, Leaderboard, Points
- **Services**: TokenService, PointsService
- **Models**: DTOs for API requests and responses

## Getting Started

### Prerequisites

- .NET 10 SDK
- Docker and Docker Compose (for local development)
- PostgreSQL (if running without Docker)

### Local Development with Docker

1. Navigate to the docker directory:
   ```bash
   cd docker
   ```

2. Start the services:
   ```bash
   docker-compose up -d
   ```

3. The API will be available at: http://localhost:8080
4. Swagger UI will be available at: http://localhost:8080

### Local Development without Docker

1. Update connection string in `appsettings.json`:
   ```json
   "ConnectionStrings": {
     "Default": "Host=localhost;Port=5432;Database=homeboard;Username=postgres;Password=yourpassword"
   }
   ```

2. Run migrations:
   ```bash
   cd backend/src/HomeBoard.Api
   dotnet ef database update
   ```

3. Set a JWT signing key once (at least 32 bytes; there is no default, and the API won't start
   without one):
   ```bash
   dotnet user-secrets set Jwt:SigningKey "$(openssl rand -base64 48)"
   ```

4. Run the application:
   ```bash
   dotnet run
   ```

## Database Migrations

Create a new migration:
```bash
cd backend/src/HomeBoard.Api
dotnet ef migrations add MigrationName --project ../HomeBoard.Infrastructure
```

Apply migrations:
```bash
dotnet ef database update
```

## First Admin User

On first start with an empty database, the application creates an admin user `admin`. Its
password is the `Seed:AdminPassword` setting (environment variable `Seed__AdminPassword`) or, when
that is not set, a random password printed once in the log ("Created the first admin user").
Change it after the first login.

## API Endpoints

### Authentication
- `POST /api/auth/login` - User login
- `POST /api/auth/refresh` - Refresh access token
- `POST /api/auth/logout` - User logout

### Users (Admin only)
- `GET /api/users` - Get all users
- `POST /api/users` - Create new user
- `PATCH /api/users/{id}` - Update user
- `POST /api/users/{id}/reset-password` - Reset user password

### Tasks
- `GET /api/tasks/definitions` - Get all task definitions
- `POST /api/tasks/definitions` - Create task definition (Admin)
- `POST /api/tasks/assignments` - Create task assignment (Admin)
- `PATCH /api/tasks/assignments/{id}` - Update assignment (Admin)
- `POST /api/tasks/{assignmentId}/complete` - Mark task as completed

### Kid Mode
- `GET /api/me/today` - Get today's tasks for current user

### Verification (Admin only)
- `GET /api/verification/pending` - Get pending verifications
- `POST /api/verification/{completionId}/verify` - Verify task completion
- `POST /api/verification/{completionId}/reject` - Reject task completion

### Points & Leaderboard
- `GET /api/leaderboard?period=week|month|all` - Get leaderboard
- `GET /api/users/{id}/points` - Get user points and history

### Health Check
- `GET /health` - API health check

## Business Rules

### Task Completion Flow
1. User marks task as completed (status: Completed)
2. Admin verifies or rejects the completion
3. Points are awarded only upon verification
4. Verification is idempotent (no duplicate points)

### Points System
- Points are stored in a ledger (PointsLedger)
- Total points are calculated by summing all entries
- Points can be positive (earned) or negative (spent on rewards)
- All point changes are auditable

## Configuration

Key configuration settings in `appsettings.json`:

`Jwt:SigningKey` is not in these files: set it with the `Jwt__SigningKey` environment variable
(Docker) or user secrets (local), at least 32 bytes.

Login attempts are limited to 10 per minute per client address (HTTP 429 after that). The
calendar accepts at most 62 days per request and analytics at most 366 days.

```json
{
  "ConnectionStrings": {
    "Default": "Host=db;Port=5432;Database=homeboard;..."
  },
  "Jwt": {
    "Issuer": "HomeBoard",
    "Audience": "HomeBoard"
  },
  "App": {
    "Timezone": "Europe/Oslo"
  }
}
```

## Testing

Run tests:
```bash
cd backend/tests/HomeBoard.Tests
dotnet test
```

## Deployment

### Azure Deployment (Future)
- Configure Azure App Service
- Set up Azure Database for PostgreSQL
- Configure environment variables
- Enable Application Insights

## Contributing

This is a learning project. Feel free to explore and modify as needed.

## License

MIT
