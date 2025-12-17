# Home Board API Documentation

## Base URL
- Development: `http://localhost:8080`
- Production: TBD

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
  "password": "Admin123!"
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

#### Refresh Token
```http
POST /api/auth/refresh
Content-Type: application/json

{
  "refreshToken": "abc123..."
}
```

#### Logout
```http
POST /api/auth/logout
Authorization: Bearer <token>
```

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
- Development: http://localhost:8080
