# Home Board Architecture

## System Overview

Home Board is a family management application focused on chores and rewards. The system follows a client-server architecture with clean separation of concerns.

## Architecture Layers

### Presentation Layer (Frontend)
- **Technology**: Flutter Web
- **Responsibility**: User interface and user experience
- **Key Features**:
  - Tablet-first responsive design
  - Kid mode (simplified UI for children)
  - Admin mode (management interface for parents)

### API Layer (Backend)
- **Technology**: ASP.NET Core Web API (.NET 8)
- **Responsibility**: Business logic and data access
- **Key Features**:
  - RESTful API endpoints
  - JWT authentication
  - Role-based authorization
  - Swagger documentation

### Data Layer
- **Technology**: PostgreSQL with Entity Framework Core
- **Responsibility**: Data persistence and integrity
- **Key Features**:
  - Relational data model
  - Audit trails via ledger pattern
  - Database migrations

## Domain Model

### Core Entities

```
User
├── TaskDefinition (created by)
├── TaskAssignment (assigned to)
├── TaskCompletion (completed by)
├── PointsLedger (points for)
└── RewardRedemption (redeemed by)

TaskDefinition
└── TaskAssignment (many assignments)
    └── TaskCompletion (many completions)

PointsLedger
└── Ledger-based accounting (no balance field)

Reward
└── RewardRedemption (many redemptions)

FamilySettings
└── Single row configuration
```

## Authentication & Authorization

### JWT Token Flow
1. User logs in with username/password
2. Server validates credentials
3. Server generates JWT access token (1 hour expiry)
4. Server generates refresh token
5. Client includes access token in Authorization header
6. Server validates token on each request

### Roles
- **Admin**: Full access (parents)
- **User**: Limited access (children)

## Key Business Flows

### Task Completion & Verification Flow

```
1. User marks task as completed
   ├── Status: Completed
   └── No points awarded yet

2. Admin reviews completion
   ├── Verify → Status: Verified
   │   ├── Create PointsLedger entry
   │   └── Award points
   │
   └── Reject → Status: Rejected
       └── Optional rejection reason
```

### Points Ledger Pattern

Instead of storing current balance, all point changes are recorded:

```
PointsLedger
├── User A: +10 (Task verified)
├── User A: +5 (Bonus)
├── User A: -15 (Reward redeemed)
└── User A Total: SUM(PointsDelta) = 0
```

Benefits:
- Full audit trail
- Immutable history
- Easy to calculate balances for any time period
- Supports leaderboard filtering by date range

## Scalability Considerations

### Current Implementation
- Monolithic API
- Single database
- Suitable for single family usage

### Future Enhancements
- Multi-tenancy support (multiple families)
- Background job processing (scheduled tasks)
- Caching layer (Redis)
- CDN for static assets
- Horizontal scaling with load balancer

## Security Features

### Implemented
- Password hashing (BCrypt)
- JWT authentication
- Role-based authorization
- HTTPS support
- CORS configuration

### Future Enhancements
- Rate limiting
- Refresh token rotation
- Account lockout after failed attempts
- Password complexity requirements
- Two-factor authentication

## Data Integrity

### Constraints
- Unique username per user
- One completion per task per day
- Immutable point ledger entries
- Soft deletes via IsActive flags

### Idempotency
- Task verification checks for existing point awards
- Prevents duplicate point grants

## API Design Principles

### RESTful Conventions
- Resource-based URLs
- HTTP verbs (GET, POST, PATCH, DELETE)
- Standard status codes
- JSON request/response bodies

### Feature-Based Organization
Controllers are organized by feature:
- Auth → Authentication
- Users → User management
- Tasks → Task definitions & assignments
- Me → Current user context
- Verification → Admin verification queue
- Leaderboard → Points rankings
- Points → Point history

## Deployment Architecture

### Development (Docker Compose)
```
┌─────────────────┐
│   Browser       │
└────────┬────────┘
         │ HTTP
         ▼
┌─────────────────┐
│   API Container │
│   (Port 8080)   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   DB Container  │
│   PostgreSQL    │
│   (Port 5432)   │
└─────────────────┘
```

### Production (Azure - Future)
```
┌─────────────────┐
│   CDN           │
│   Static Assets │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   App Service   │
│   API           │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Azure DB for  │
│   PostgreSQL    │
└─────────────────┘
```

## Testing Strategy

### Unit Tests
- Domain logic
- Service methods
- Points calculation
- Verification idempotency

### Integration Tests
- API endpoints
- Database operations
- Authentication flow
- End-to-end task completion

### Frontend Tests
- Widget tests
- API client mocks
- User interaction flows

## Error Handling

### API Responses
- 200 OK: Success
- 201 Created: Resource created
- 400 Bad Request: Validation error
- 401 Unauthorized: Authentication required
- 403 Forbidden: Insufficient permissions
- 404 Not Found: Resource not found
- 409 Conflict: Duplicate or constraint violation
- 500 Internal Server Error: Server error

## Monitoring & Observability

### Current
- Health check endpoint
- Console logging
- EF Core query logging

### Future
- Application Insights (Azure)
- Structured logging (Serilog)
- Performance metrics
- Error tracking
