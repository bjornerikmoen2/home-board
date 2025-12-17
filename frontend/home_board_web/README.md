# Home Board Frontend

A Flutter Web application for the Home Board family task management system.

## Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.24.0 or higher)
- Chrome or Edge browser for web development

## Project Structure

```
lib/
├── core/
│   ├── constants/       # App-wide constants
│   ├── network/         # Dio HTTP client and interceptors
│   ├── router/          # go_router configuration
│   ├── storage/         # SharedPreferences wrapper
│   └── theme/           # App theme configuration
├── features/
│   ├── admin/           # Admin panel screens
│   │   └── screens/
│   ├── auth/            # Authentication
│   │   ├── models/
│   │   ├── providers/
│   │   ├── repositories/
│   │   └── screens/
│   ├── home/            # Home dashboard
│   │   └── screens/
│   ├── leaderboard/     # Points leaderboard
│   │   └── screens/
│   └── today/           # Today's tasks (kid mode)
│       └── screens/
└── main.dart            # App entry point
```

## Setup Instructions

1. **Install Flutter dependencies:**
   ```bash
   cd frontend/home_board_web
   flutter pub get
   ```

2. **Generate code (Freezed, JSON serialization, Riverpod):**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. **Ensure the backend API is running:**
   - Backend should be accessible at `http://localhost:8080`
   - See backend README for Docker setup instructions

4. **Run the application:**
   ```bash
   flutter run -d chrome
   ```
   Or for hot reload development:
   ```bash
   flutter run -d chrome --web-hot-reload
   ```

## Architecture

### State Management
- **Riverpod** for dependency injection and state management
- **riverpod_generator** for code generation
- Providers are located in `features/*/providers/`

### Routing
- **go_router** for declarative routing
- Authentication guards redirect unauthenticated users to login
- Routes defined in `core/router/app_router.dart`

### HTTP Client
- **Dio** for API communication
- Auth interceptor automatically adds JWT Bearer tokens
- Base URL: `http://localhost:8080/api`

### Models
- **Freezed** for immutable data models
- **json_serializable** for JSON serialization
- Models located in `features/*/models/`

## Key Features

### Kid Mode (Today's Tasks)
- Large, touch-friendly buttons optimized for tablets
- Visual feedback on task completion
- Points displayed prominently
- Minimal navigation for ease of use

### Admin Mode
- User management
- Task definition creation and scheduling
- Verification queue for task completions
- Analytics and leaderboard view

### Authentication
- JWT-based authentication
- Automatic token refresh
- Role-based routing (Admin vs User)
- Default admin credentials:
  - Username: `admin`
  - Password: `Admin123!`

## API Integration

The app integrates with the following API endpoints:

### Auth
- `POST /api/auth/login` - User login
- `POST /api/auth/refresh` - Refresh access token

### User
- `GET /api/me` - Get current user info
- `GET /api/me/today` - Get today's tasks for current user

### Tasks
- `GET /api/tasks` - List all task definitions (admin)
- `POST /api/tasks` - Create task definition (admin)
- `POST /api/tasks/{id}/complete` - Mark task as complete

### Verification
- `GET /api/verification/pending` - Get pending completions (admin)
- `POST /api/verification/{id}/verify` - Verify completion (admin)
- `POST /api/verification/{id}/reject` - Reject completion (admin)

### Leaderboard
- `GET /api/leaderboard?period=week|month|all` - Get leaderboard

## Development

### Code Generation
After modifying Freezed models or adding new providers, run:
```bash
flutter pub run build_runner watch
```
This will auto-generate code on file changes.

### Testing
```bash
flutter test
```

### Build for Production
```bash
flutter build web --release
```
Output will be in `build/web/`

## Troubleshooting

### "flutter: command not found"
Ensure Flutter is installed and added to your PATH. Run:
```bash
flutter doctor
```

### API Connection Issues
- Verify backend is running: `docker ps` should show `home-board-api` container
- Check API is accessible: Open `http://localhost:8080/swagger` in browser
- Verify no CORS issues in browser console

### Build Runner Errors
If you get conflicts, delete generated files:
```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

## Technology Stack

- **Framework:** Flutter 3.24+
- **State Management:** Riverpod 2.6.1, riverpod_generator 2.6.2
- **Routing:** go_router 14.6.2
- **HTTP Client:** Dio 5.7.0
- **Models:** Freezed 2.5.7, json_serializable 6.8.0
- **Storage:** shared_preferences 2.3.3

## Next Steps

1. ✅ Basic UI screens created
2. ⏳ Create Task and Leaderboard models with Freezed
3. ⏳ Create repositories for API integration
4. ⏳ Create Riverpod providers for state management
5. ⏳ Connect screens to real API data
6. ⏳ Add form validation and error handling
7. ⏳ Implement admin features (user management, task creation)
8. ⏳ Add verification workflow UI
9. ⏳ Style improvements and responsive design refinements
10. ⏳ Add loading states and error boundaries

## License

Proprietary - For internal use only
