# Home Board — Copilot Project Instructions

## Project Overview
Home Board is a tablet-first web application for families.  
The initial focus is **chores and rewards for kids**, but the platform must be extensible to support additional home features later (dashboards, routines, announcements, home automation, etc.).

This is a learning project using:
- Flutter Web (frontend)
- ASP.NET Core Web API (.NET 8) (backend)
- PostgreSQL
- Docker for local development
- Azure for future hosting

---

## Core Concepts
- **Roles**
  - Admin (parent)
  - User (child)

- **Initial Feature Domain**
  - Chores
  - Points
  - Rewards
  - Leaderboard
  - Calendar
  - Analytics

Design the system using **feature-based modularity**, not monolithic controllers.

---

## Tech Stack

### Frontend
- Flutter Web
- Tablet-first responsive design
- State management: Riverpod (preferred) or Bloc
- Routing: go_router
- HTTP client: Dio or http
- Charts (later): fl_chart

### Backend
- ASP.NET Core Web API (.NET 8)
- Entity Framework Core
- PostgreSQL
- JWT authentication with refresh tokens
- Role-based authorization (Admin / User)
- Swagger / OpenAPI enabled

### Local Development
- Docker + docker-compose
- Services:
  - api (ASP.NET Core)
  - db (PostgreSQL)
- Named volumes for database persistence

---

## Repository Structure
- home-board/
    - backend/
        - src/
            - HomeBoard.Api/
            - HomeBoard.Domain/
            - HomeBoard.Infrastructure/
        - tests/
            - HomeBoard.Tests/
    - frontend/
        -   home_board_web/ # Flutter project
    - docker/
        - docker-compose.yml
    - docs/
        - architecture.md
        - api.md
    - COPILOT_INSTRUCTIONS.md

---

## Domain Model (Initial)

### Users
- User
  - Id (uuid)
  - Username
  - DisplayName
  - PasswordHash
  - Role (Admin | User)
  - IsActive
  - CreatedAt
  - LastLoginAt

### Chores
- TaskDefinition
  - Id
  - Title
  - Description
  - DefaultPoints
  - IsActive
  - CreatedByUserId
  - CreatedAt

- TaskAssignment
  - Id
  - TaskDefinitionId
  - AssignedToUserId
  - ScheduleType (Daily | Weekly | Once)
  - DaysOfWeek (for Weekly)
  - StartDate
  - EndDate
  - DueTime
  - IsActive

- TaskCompletion
  - Id
  - TaskAssignmentId
  - Date (local date)
  - CompletedByUserId
  - CompletedAt
  - Status (Completed | Verified | Rejected)
  - VerifiedByUserId
  - VerifiedAt
  - RejectionReason

### Points (Ledger-based)
- PointsLedger
  - Id
  - UserId
  - SourceType (TaskVerified | Bonus | RewardRedeemed | Adjustment)
  - SourceId (nullable)
  - PointsDelta (positive or negative)
  - Note
  - CreatedByUserId
  - CreatedAt

### Rewards
- Reward
  - Id
  - Title
  - Description
  - CostPoints
  - IsActive

- RewardRedemption
  - Id
  - RewardId
  - UserId
  - RedeemedAt
  - Status (Requested | Approved | Rejected | Fulfilled)
  - HandledByUserId
  - HandledAt

### Settings
- FamilySettings
  - Id (single row)
  - Timezone
  - PointToMoneyRate
  - WeekStartsOn

---

## Business Rules (Important)

### Task Completion
- Users can mark assigned tasks as completed for the current date.
- Completing a task does NOT immediately grant points.

### Verification
- Admin must verify a completed task.
- Only verification grants points.
- Verification must be idempotent (no duplicate point grants).

### Points
- Points are calculated from PointsLedger only.
- Never store “current points” directly.
- Ledger entries must be auditable.

### Leaderboard
- Calculated dynamically from PointsLedger.
- Supports time ranges (week, month, all-time).

---

## API Endpoints (Initial)

### Auth
- POST /api/auth/login
- POST /api/auth/refresh
- POST /api/auth/logout

### Users (Admin)
- GET /api/users
- POST /api/users
- PATCH /api/users/{id}
- POST /api/users/{id}/reset-password

### Tasks
- GET /api/tasks/definitions
- POST /api/tasks/definitions
- POST /api/tasks/assignments
- PATCH /api/tasks/assignments/{id}

### Kid Mode
- GET /api/me/today
- POST /api/tasks/{assignmentId}/complete

### Verification (Admin)
- GET /api/verification/pending
- POST /api/verification/{completionId}/verify
- POST /api/verification/{completionId}/reject

### Points & Leaderboard
- GET /api/leaderboard
- GET /api/users/{id}/points

### Rewards (Phase 2)
- GET /api/rewards
- POST /api/rewards
- POST /api/rewards/{id}/redeem

---

## Docker & Environment

### docker-compose goals
- API exposed on http://localhost:8080
- PostgreSQL on port 5432
- Persistent volume for database

### API environment variables
- ConnectionStrings__Default
- Jwt__Issuer
- Jwt__Audience
- Jwt__SigningKey
- App__Timezone=Europe/Oslo

---

## UX Guidelines

### Kid Mode
- Big buttons
- Minimal navigation
- “Today” is default screen
- Visual feedback on completion (icons, colors)

### Admin Mode
- User management
- Task creation & scheduling
- Verification queue
- Leaderboard & analytics

---

## Testing Strategy

### Backend
- Unit tests for:
  - Points awarding logic
  - Verification idempotency
- Integration tests for:
  - Auth
  - Complete → verify → ledger flow

### Frontend
- Widget tests for:
  - Today screen
  - Task completion UI
- API client tests with mocked responses

---

## Copilot Task Instructions

When scaffolding this project:

- Create an ASP.NET Core Web API (.NET 8)
- Use EF Core with PostgreSQL
- Implement JWT auth with roles
- Create entities and migrations for all domain models
- Seed a default admin user in development
- Add Swagger and health check endpoint
- Create docker-compose.yml for API + Postgres
- Prepare the project for Azure deployment later

Follow clean architecture principles and feature-based organization.

Do NOT over-engineer.
Focus on correctness, clarity, and extensibility.
