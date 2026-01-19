# Home Board

A family chores and rewards management system designed for families with children. Parents can create tasks, verify completions, and award points. Kids can view their tasks, mark them complete, and track their progress on a leaderboard.

## Features

- 📋 **Task Management** - Create and assign recurring or one-time tasks
- ✅ **Task Verification** - Parents approve completed tasks before awarding points
- 🏆 **Leaderboard** - Kids compete for top spots with weekly/monthly rankings
- 📺 **Scoreboard Display** - Public read-only view perfect for family tablets showing current standings and pending tasks
- 💰 **Points System** - Track earned points with complete audit history
- 👥 **Multi-User** - Support for parents (admins) and children (users)
- 🔒 **Secure** - JWT authentication with role-based authorization
- 🌙 **Dark Mode** - User-specific theme preference with automatic sync across devices
- 📱 **Tablet-First** - Optimized for family tablet usage
- 🎯 **Group Tasks** - Assign tasks to all users at once
- ⚙️ **Flexible Scheduling** - Daily, weekly, once, during-week, and during-month task types

## Tech Stack

### Backend
- **ASP.NET Core 9** - Web API
- **PostgreSQL** - Database
- **Entity Framework Core** - ORM
- **JWT** - Authentication

### Frontend
- **Flutter Web** - Cross-platform web application
- **Riverpod** - State management
- **Dio** - HTTP client

### Infrastructure
- **Docker** - Containerization
- **Docker Compose** - Multi-container orchestration
- **Nginx** - Web server for Flutter frontend

## Quick Start with Docker

### Prerequisites
- Docker Desktop installed and running
- Git

### Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/bjornerikmoen2/home-board.git
   cd home-board
   ```

2. **Create environment file**:
   ```bash
   # Copy the example file
   cp .env.example .env
   
   # Or create .env directly with these values:
   cat > .env << EOF
   POSTGRES_DB=homeboard
   POSTGRES_USER=homeboarduser
   POSTGRES_PASSWORD=your_secure_password
   JWT_SIGNING_KEY=your_jwt_signing_key_min_32_chars_long
   BACKEND_PORT=8080
   FRONTEND_PORT=3001
   EOF
   ```
   
   **Important**: Change the passwords and JWT key to secure values!
   
   **Note**: Port configuration is optional. If not specified, the application uses defaults:
   - `BACKEND_PORT` defaults to `8080`
   - `FRONTEND_PORT` defaults to `3001`

3. **Start all services**:
   ```bash
   docker-compose up -d
   ```
   
   The compose file will:
   - Pull pre-built images from GitHub Container Registry
   - Start PostgreSQL with health checks
   - Wait for database to be healthy before starting the API
   - Automatically run database migrations
   - Configure automatic restarts on failure

4. **Wait for services to start**:
   The database needs to initialize and the API will run migrations automatically.
   The database healthcheck ensures services start in the correct order.
   Wait about 30-60 seconds for everything to be ready.

5. **Access the application**:
   - **Frontend**: http://localhost:3001
   - **API Swagger**: http://localhost:8080/swagger
   - **Health Check**: http://localhost:8080/health

6. **Login with default credentials**:
   - Username: `admin`
   - Password: `Admin123!`
   
   **⚠️ Change this password immediately after first login!**

### Managing Services

```bash
# View logs
docker-compose logs -f api    # API logs
docker-compose logs -f web    # Frontend logs
docker-compose logs -f db     # Database logs

# Stop services
docker-compose down

# Stop and remove all data (fresh start)
docker-compose down -v

# Restart a single service
docker-compose restart api
docker-compose restart web

# Rebuild after code changes
docker-compose build api      # Rebuild API
docker-compose build web      # Rebuild frontend
docker-compose up -d          # Restart with new images
```

## Development Setup (Without Docker)

### Backend

1. **Prerequisites**:
   - .NET 9 SDK
   - PostgreSQL installed locally

2. **Configure database**:
   Update `backend/src/HomeBoard.Api/appsettings.Development.json`:
   ```json
   {
     "ConnectionStrings": {
       "Default": "Host=localhost;Port=5432;Database=homeboard;Username=postgres;Password=yourpassword"
     }
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
   API will be available at http://localhost:8080

### Frontend

1. **Prerequisites**:
   - Flutter SDK (3.x or higher)

2. **Install dependencies**:
   ```bash
   cd frontend/home_board_web
   flutter pub get
   ```

3. **Generate code** (for freezed models):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**:
   ```bash
   flutter run -d chrome
   ```

## Project Structure

```
home-board/
├── backend/                    # ASP.NET Core API
│   ├── src/
│   │   ├── HomeBoard.Api/      # API controllers and startup
│   │   ├── HomeBoard.Domain/   # Domain entities and enums
│   │   └── HomeBoard.Infrastructure/  # Data access and migrations
│   └── tests/                  # Unit and integration tests
├── frontend/                   # Flutter web application
│   └── home_board_web/
│       ├── lib/
│       │   ├── core/           # Core utilities and providers
│       │   ├── features/       # Feature modules
│       │   └── l10n/           # Localization
│       └── build/              # Build output
├── docs/                       # Documentation
│   ├── api.md                  # API endpoint documentation
│   └── architecture.md         # System architecture
├── bruno/                      # API testing collection
└── docker-compose.yml          # Docker orchestration
```

## Common Tasks

### Create a New User (Child)

1. Login as admin via Swagger UI at http://localhost:8080/swagger
2. Use the `/api/users` POST endpoint:
   ```json
   {
     "username": "johnny",
     "displayName": "Johnny",
     "password": "Kid123!",
     "role": 1
   }
   ```

### Create a Task Definition

POST to `/api/tasks/definitions`:
```json
{
  "title": "Make Bed",
  "description": "Make your bed every morning",
  "defaultPoints": 5
}
```

### Assign a Task

POST to `/api/tasks/assignments`:
```json
{
  "taskDefinitionId": "<uuid-from-previous-step>",
  "assignedToUserId": "<johnny-user-id>",
  "scheduleType": 0,
  "daysOfWeek": 127,
  "dueTime": "09:00:00"
}
```

**Schedule Types:**
- `0` = Daily
- `1` = Weekly  
- `2` = Once

**Days of Week (bit flags, sum them):**
- Sunday=1, Monday=2, Tuesday=4, Wednesday=8, Thursday=16, Friday=32, Saturday=64
- Example: `127` = All days (1+2+4+8+16+32+64)

### Complete and Verify a Task

1. **Kid marks task complete**:
   - GET `/api/me/today` to see assigned tasks
   - POST `/api/tasks/{assignmentId}/complete`

2. **Admin verifies**:
   - GET `/api/verification/pending`
   - POST `/api/verification/{completionId}/verify` with points:
     ```json
     {
       "pointsAwarded": 10
     }
     ```

### Scoreboard Display

The scoreboard feature provides a public, read-only display perfect for showing on a shared family tablet or screen.

**Key Features:**
- **Public Access**: No login required - accessible via `/scoreboard` route
- **Real-Time Updates**: Shows current standings and pending tasks for all family members
- **Points Leaderboard**: Users ranked by total points earned
- **Pending Tasks**: Displays today's incomplete tasks for each user
- **Shared Tasks**: Shows tasks assigned to all users (group tasks)
- **Theme Sync**: Automatically uses the admin's dark/light mode preference
- **Language Sync**: Uses admin's preferred language (English/Norwegian)
- **Profile Images**: Displays user profile pictures when available

**How to Access:**
1. Navigate to `http://localhost:3001/scoreboard` (or your domain)
2. View is automatically updated when tasks are completed or points are awarded
3. No authentication needed - perfect for display on a shared device

**Enabling the Scoreboard:**
The scoreboard can be enabled/disabled in the Family Settings:
1. Login as admin
2. Go to Settings
3. Toggle "Enable Scoreboard" on/off

**What's Displayed:**
- **User Cards**: Each family member gets a card showing:
  - Name and profile picture
  - Total points earned
  - Today's pending personal tasks
- **Shared Tasks Section**: Tasks assigned to all users appear at the top
- **Task Details**: Each task shows title and point value

**Best Practices:**
- Mount a tablet in a common area (kitchen, hallway) showing the scoreboard
- Kids can see what tasks need to be done without logging in
- Creates friendly competition and motivation
- Parents can quickly see who's completed their tasks

## Deployment

### Production Deployment

The docker-compose.yml file uses pre-built images from GitHub Container Registry, making deployment straightforward.

1. **Set environment variables** on your server:
   ```bash
   # Create .env file with production values
   POSTGRES_DB=homeboard_prod
   POSTGRES_USER=homeboarduser
   POSTGRES_PASSWORD=<strong_password>
   JWT_SIGNING_KEY=<strong_random_key_at_least_32_chars>
   BACKEND_PORT=8080
   FRONTEND_PORT=3001
   ```

2. **Update docker-compose.yml** for production:
   - Change `ASPNETCORE_ENVIRONMENT` to `Production` in the `api` service
   - Configure specific CORS origins (uncomment and set in docker-compose.yml)
   - Set `App__Timezone` if different from default `Europe/Oslo`
   - Set up proper SSL/TLS termination (reverse proxy recommended)
   - Configure ports via `.env` if different from defaults

3. **Deploy**:
   ```bash
   docker-compose pull  # Pull latest images
   docker-compose up -d
   ```
   
   Services will:
   - Start with automatic restart on failure
   - Wait for database health checks before starting API
   - Run migrations automatically
   - Recover from failures without manual intervention

4. **First-time setup**:
   - Database tables are created automatically via migrations
   - Default admin user is created on first startup
   - Login and change the default password immediately!

### Environment Variables

Required environment variables in `.env`:

| Variable | Description | Example |
|----------|-------------|---------|
| `POSTGRES_DB` | Database name | `homeboard` |
| `POSTGRES_USER` | Database user | `homeboarduser` |
| `POSTGRES_PASSWORD` | Database password | `securepassword123` |
| `JWT_SIGNING_KEY` | JWT signing key (min 32 chars) | `your-secret-key-min-32-chars` |

Optional environment variables:

| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `BACKEND_PORT` | Port for the backend API | `8080` | `8080` |
| `FRONTEND_PORT` | Port for the frontend web application | `3001` | `3001` |
| `Cors__AllowedOrigins` | Comma-separated allowed CORS origins | `*` (all) | `https://yourdomain.com,https://www.yourdomain.com` |
| `App__Timezone` | Application timezone for date calculations | `Europe/Oslo` | `America/New_York` |

**Port Configuration:**
- Both `BACKEND_PORT` and `FRONTEND_PORT` are optional
- If not specified in `.env`, the application uses the default values
- The frontend automatically proxies API requests to the configured backend port
- Useful for avoiding port conflicts or deploying multiple instances

**CORS Configuration:**
- Default (`*`) allows all origins - suitable for development or flexible deployments
- For production, set specific origins in docker-compose.yml:
  ```yaml
  environment:
    Cors__AllowedOrigins: "https://yourdomain.com,https://www.yourdomain.com"
  ```
- Can also be configured in appsettings.json or via `.env` file
- Multiple origins separated by commas

**Service Reliability:**
- All services are configured with `restart: unless-stopped` for automatic recovery
- Database has built-in health checks to ensure availability
- API waits for database health check before starting
- Ensures proper startup order and automatic failure recovery

## API Documentation

Full API documentation is available at:
- **Interactive Swagger UI**: http://localhost:8080/swagger
- **Markdown docs**: [docs/api.md](docs/api.md)

## Architecture

For detailed architecture information, see [docs/architecture.md](docs/architecture.md).

Key architectural decisions:
- **Clean Architecture** - Separation of concerns with Domain, Infrastructure, and API layers
- **Ledger Pattern** - All point transactions recorded, no balance field
- **Task Verification Flow** - Two-step process (complete → verify) for point awards
- **JWT Authentication** - Stateless authentication with role-based authorization

## Troubleshooting

### Database connection errors

Check that the database container is healthy:
```bash
docker-compose ps
docker-compose logs db
```

The database has built-in health checks. If the API won't start, verify the database passes its health check before troubleshooting further.

### API not starting

Check API logs for migration errors:
```bash
docker-compose logs api
```

### Frontend build errors

Make sure code generation ran:
```bash
cd frontend/home_board_web
flutter pub run build_runner build --delete-conflicting-outputs
```

### Port conflicts

If ports 8080 or 3001 are in use, configure them in your `.env` file:
```bash
BACKEND_PORT=8081
FRONTEND_PORT=3002
```

No need to modify docker-compose.yml - the ports are configured via environment variables.

### Fresh start

Remove all containers and volumes:
```bash
docker-compose down -v
docker-compose up -d
```

## Contributing

1. Create a feature branch
2. Make your changes
3. Test thoroughly
4. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For issues and questions:
- Check the [API documentation](docs/api.md)
- Check the [Architecture documentation](docs/architecture.md)
- Review Docker logs: `docker-compose logs -f`
