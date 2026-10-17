# Home Board API Documentation

## Base URL
- Development: `http://localhost:8080`
- Production: Configure via your deployment

## First Admin User

On first startup with an empty database, the system creates an admin user:
- **Username**: `admin`
- **Password**: the `Seed__AdminPassword` setting, or a random password printed once in the API
  log ("Created the first admin user")

**⚠️ Important**: Change this password after your first login!

Users marked "no password required" (children on the family tablet) can only log in without a
password from the home network; from the internet that login is refused and
`GET /api/auth/no-password-users` returns an empty list (see `Auth__AllowNoPasswordLoginFromInternet`).
Admins always need a password.

## Authentication

All endpoints except `/api/auth/login` and `/health` require authentication.

Include the JWT token in the Authorization header:
```
Authorization: Bearer <your-jwt-token>
```

## API Endpoints

### Authentication

#### Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "username": "admin",
  "password": "<password>"
}
```

**Response 200 OK:**
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "abc123...",
  "user": {
    "id": "uuid",
    "username": "admin",
    "displayName": "Administrator",
    "role": "Admin"
  }
}
```

The access token is valid for an hour. The refresh token gets a new one without logging in again:
it works for 30 days, and each refresh starts a new 30 days, so a device in daily use stays logged
in. Only a hash of it is stored.

#### Refresh Token
```http
POST /api/auth/refresh
Content-Type: application/json

{
  "refreshToken": "abc123..."
}
```

**Response 200 OK:** the same as for login, with a new access token and a **new refresh token**.
Each refresh token works once; keep the new one for next time. `401 Unauthorized` when the token
is unknown, used, expired or revoked, when the user was deactivated, and for a passwordless (kid)
login refreshed from the internet or after the child got a password.

#### Logout
```http
POST /api/auth/logout
Content-Type: application/json

{
  "refreshToken": "abc123..."
}
```

Revokes the refresh token, so this device can't get new access tokens; the access token itself
runs out within the hour. The body is optional and the answer is always `200 OK`. Resetting a
user's password revokes all their refresh tokens.

---

### Users (Admin Only)

#### Get All Users
```http
GET /api/users
Authorization: Bearer <token>
```

**Response 200 OK:**
```json
[
  {
    "id": "uuid",
    "username": "john",
    "displayName": "John Doe",
    "role": "User"
  }
]
```

#### Create User
```http
POST /api/users
Authorization: Bearer <token>
Content-Type: application/json

{
  "username": "johnny",
  "displayName": "Johnny Doe",
  "password": "Password123!",
  "role": 1
}
```

**Response 201 Created:**
```json
{
  "id": "uuid",
  "username": "johnny",
  "displayName": "Johnny Doe",
  "role": "User"
}
```

#### Update User
```http
PATCH /api/users/{id}
Authorization: Bearer <token>
Content-Type: application/json

{
  "displayName": "John Updated",
  "isActive": true
}
```

#### Reset Password
```http
POST /api/users/{id}/reset-password
Authorization: Bearer <token>
Content-Type: application/json

{
  "newPassword": "NewPassword123!"
}
```

---

### Tasks

#### Get Task Definitions
```http
GET /api/tasks/definitions
Authorization: Bearer <token>
```

**Response 200 OK:**
```json
[
  {
    "id": "uuid",
    "title": "Clean Room",
    "description": "Clean and organize bedroom",
    "defaultPoints": 10,
    "isActive": true
  }
]
```

#### Create Task Definition (Admin)
```http
POST /api/tasks/definitions
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "Make Bed",
  "description": "Make your bed every morning",
  "defaultPoints": 5
}
```

#### Create Task Assignment (Admin)
```http
POST /api/tasks/assignments
Authorization: Bearer <token>
Content-Type: application/json

{
  "taskDefinitionId": "uuid",
  "assignedToUserId": "uuid",
  "scheduleType": 0,
  "daysOfWeek": 127,
  "startDate": "2025-01-01",
  "dueTime": "09:00:00"
}
```

**Schedule Types:**
- 0 = Daily
- 1 = Weekly
- 2 = Once

**Days of Week (Flags):**
- 1 = Sunday
- 2 = Monday
- 4 = Tuesday
- 8 = Wednesday
- 16 = Thursday
- 32 = Friday
- 64 = Saturday
- 127 = All days (1+2+4+8+16+32+64)

#### Update Task Assignment (Admin)
```http
PATCH /api/tasks/assignments/{id}
Authorization: Bearer <token>
Content-Type: application/json

{
  "isActive": false,
  "dueTime": "10:00:00"
}
```

#### Complete Task
```http
POST /api/tasks/{assignmentId}/complete
Authorization: Bearer <token>
```

**Response 200 OK:**
```json
{
  "message": "Task marked as completed",
  "completionId": "uuid"
}
```

---

### Kid Mode

#### Get Today's Tasks
```http
GET /api/me/today
Authorization: Bearer <token>
```

**Response 200 OK:**
```json
[
  {
    "assignmentId": "uuid",
    "title": "Make Bed",
    "description": "Make your bed every morning",
    "points": 5,
    "dueTime": "09:00:00",
    "isCompleted": true,
    "completionId": "uuid",
    "status": "Verified"
  }
]
```

**Task Status:**
- Completed = 0
- Verified = 1
- Rejected = 2

---

### Verification (Admin Only)

#### Get Pending Verifications
```http
GET /api/verification/pending
Authorization: Bearer <token>
```

**Response 200 OK:**
```json
[
  {
    "completionId": "uuid",
    "date": "2025-12-17",
    "taskTitle": "Clean Room",
    "completedByName": "Johnny",
    "completedByUserId": "uuid",
    "completedAt": "2025-12-17T15:30:00Z",
    "defaultPoints": 10
  }
]
```

#### Verify Task
```http
POST /api/verification/{completionId}/verify
Authorization: Bearer <token>
Content-Type: application/json

{
  "pointsAwarded": 10
}
```

**Response 200 OK:**
```json
{
  "message": "Task verified and points awarded",
  "pointsAwarded": 10
}
```

#### Reject Task
```http
POST /api/verification/{completionId}/reject
Authorization: Bearer <token>
Content-Type: application/json

{
  "reason": "Task not completed properly"
}
```

---

### Leaderboard

#### Get Leaderboard
```http
GET /api/leaderboard?period=week
Authorization: Bearer <token>
```

**Query Parameters:**
- `period`: `week`, `month`, or `all` (default: `all`)

**Response 200 OK:**
```json
[
  {
    "userId": "uuid",
    "displayName": "Johnny",
    "totalPoints": 145,
    "rank": 1
  },
  {
    "userId": "uuid",
    "displayName": "Sarah",
    "totalPoints": 120,
    "rank": 2
  }
]
```

---

### Points

#### Get User Points
```http
GET /api/users/{id}/points
Authorization: Bearer <token>
```

**Response 200 OK:**
```json
{
  "userId": "uuid",
  "displayName": "Johnny",
  "totalPoints": 145,
  "recentEntries": [
    {
      "id": "uuid",
      "sourceType": "TaskVerified",
      "pointsDelta": 10,
      "note": "Verified: Clean Room",
      "createdAt": "2025-12-17T16:00:00Z"
    }
  ]
}
```

---

### Integrations (API key)

Data for other home services, such as a personal assistant. These endpoints don't use a user
login: they need a shared key in the `X-Api-Key` header. While their key is not configured they
answer `404 Not Found`; a missing or wrong key gets `401 Unauthorized`.

- Reading chores and points takes `Integrations:ApiKey` (environment variable `Integrations__ApiKey`).
- Approving or rejecting done chores and giving bonus points takes a separate key,
  `Integrations:WriteApiKey` (`Integrations__WriteApiKey`), so a service can be allowed to read
  without being allowed to change anything. The changes are recorded under the admin whose
  username is `Integrations:ActAsUser`, or else the first admin created.

#### Get Chores
```http
GET /api/integrations/chores?startDate=2026-10-19&endDate=2026-10-25
X-Api-Key: <key>
```

Both dates are optional: the default is today in the family's timezone, and `endDate` defaults to
`startDate`. At most 62 days per request.

Every chore of every family member on each day, counted like the kids' "today" list (chores
whose due time has passed are included). A "during the week/month" chore appears every day until
it is done, and on the day it was done.

**Response 200 OK:**
```json
{
  "timezone": "Europe/Oslo",
  "today": "2026-10-19",
  "startDate": "2026-10-19",
  "endDate": "2026-10-25",
  "chores": [
    {
      "date": "2026-10-19",
      "assignmentId": "guid",
      "title": "Make bed",
      "description": null,
      "points": 5,
      "schedule": "daily",
      "dueTime": "08:00:00",
      "assignedTo": "Ola",
      "assignedToGroup": null,
      "status": "verified",
      "completedBy": "Ola",
      "completedAt": "2026-10-19T06:12:00Z",
      "completionId": "guid"
    }
  ]
}
```

- `schedule`: `daily`, `weekly`, `once`, `during_week` or `during_month`
- `assignedToGroup`: `kids` or `parents` for a chore shared by the group (`assignedTo` is then null)
- `status`: `todo`, `done` (waiting for a parent to check it), `verified` or `rejected`
- `completionId`: set once the chore is done; used to approve or reject it

#### Get Points
```http
GET /api/integrations/points
X-Api-Key: <key>
```

Each active child's points (role User), in the same terms as the scoreboard and the payout
preview, plus the done chores still waiting for a parent's approval (their points count once
approved).

**Response 200 OK:**
```json
{
  "timezone": "Europe/Oslo",
  "today": "2026-10-19",
  "pointToMoneyRate": 0.5,
  "users": [
    {
      "userId": "guid",
      "name": "Ola",
      "scoreboardPoints": 30,
      "pointsSinceLastPayout": 30,
      "moneyToPay": 15.0,
      "lastPayoutAt": "2026-10-01T18:00:00Z",
      "earnedThisWeek": 20,
      "earnedThisMonth": 30,
      "waitingForApproval": [
        { "completionId": "guid", "date": "2026-10-19", "title": "Make bed", "points": 5, "completedAt": "2026-10-19T06:12:00Z" }
      ]
    }
  ]
}
```

- `scoreboardPoints`: all points minus those paid out
- `pointsSinceLastPayout` / `moneyToPay`: as in the payout preview (never paid below zero)
- `earnedThisWeek` / `earnedThisMonth`: positive points since the start of the family's week and month

#### Approve a Done Chore
```http
POST /api/integrations/completions/{completionId}/approve
X-Api-Key: <write key>
Content-Type: application/json

{
  "pointsAwarded": 8
}
```

The same as approving in the verification queue: the person who did the chore gets its points, or
`pointsAwarded` when given (the body is optional).

**Response 200 OK:**
```json
{ "message": "Chore approved", "title": "Make bed", "completedBy": "Ola", "pointsAwarded": 5 }
```

`404 Not Found` for an unknown `completionId`; `409 Conflict` when the chore was already approved
or rejected.

#### Reject a Done Chore
```http
POST /api/integrations/completions/{completionId}/reject
X-Api-Key: <write key>
Content-Type: application/json

{
  "reason": "The bed isn't made"
}
```

No points; the reason is optional. Answers as for approving, with `"pointsAwarded": 0`.

#### Give Bonus Points
```http
POST /api/integrations/users/{userId}/bonus-points
X-Api-Key: <write key>
Content-Type: application/json

{
  "points": 15,
  "description": "Carried the shopping"
}
```

Only for active children (`userId` from Get Points), and `points` must be more than zero.

**Response 200 OK:**
```json
{ "message": "Bonus points awarded", "name": "Ola", "pointsAwarded": 15 }
```

---

### Health Check

#### Check API Health
```http
GET /health
```

**Response 200 OK:**
```json
{
  "status": "healthy",
  "timestamp": "2025-12-17T16:00:00Z"
}
```

---

## Error Responses

### 400 Bad Request
```json
{
  "message": "Validation error message"
}
```

### 401 Unauthorized
```json
{
  "message": "Invalid username or password"
}
```

### 403 Forbidden
```json
{
  "message": "Insufficient permissions"
}
```

### 404 Not Found
```json
{
  "message": "Resource not found"
}
```

### 409 Conflict
```json
{
  "message": "Username already exists"
}
```

## Rate Limiting

Not currently implemented. Future consideration.

## Swagger UI

Interactive API documentation available at:
- Development: http://localhost:8080/swagger
- Production: http://your-domain/swagger (disable in production for security)

## Database Seeding

The API automatically:
1. **Runs migrations** on startup (creates/updates database schema)
2. **Seeds initial data** if database is empty:
   - Creates the first admin user (`admin`, password from `Seed__AdminPassword` or generated and logged once)
   - Creates default family settings (timezone, point rates)

This happens in all environments, but only when the database is empty, so it's safe for production deployments.
