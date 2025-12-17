# Frontend Setup and Next Steps

## Current Status

✅ **Completed:**
- All UI screens created (Login, Home, Today's Tasks, Admin Panel, Leaderboard)
- Models defined with Freezed annotations
- Repositories for API communication
- Riverpod providers for state management
- Router with authentication guards
- Dio HTTP client with JWT interceptor
- Storage service for tokens/user data

⏳ **Pending:**
- Run build_runner to generate `.g.dart` and `.freezed.dart` files
- Test the application with the backend API

## Setup Instructions

### 1. Install Flutter

Download and install Flutter from https://flutter.dev/docs/get-started/install

Verify installation:
```bash
flutter doctor
```

### 2. Install Dependencies

```bash
cd c:\coding_fun\Code\home-board\frontend\home_board_web
flutter pub get
```

### 3. Generate Code

This is **REQUIRED** before running the app. It generates Freezed models, JSON serialization, and Riverpod providers:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This will create:
- `*.freezed.dart` files for all Freezed models
- `*.g.dart` files for JSON serialization and Riverpod generators
- Approximately 15+ generated files

### 4. Start Backend

Make sure the backend is running:
```bash
cd c:\coding_fun\Code\home-board\backend
docker-compose up -d
```

Verify:
- API: http://localhost:8080
- Swagger: http://localhost:8080/swagger

### 5. Run Frontend

```bash
flutter run -d chrome
```

Or for development with hot reload:
```bash
flutter run -d chrome --web-hot-reload
```

## Default Login Credentials

- **Username:** admin
- **Password:** Admin123!

## Feature Overview

### Login Screen
- Email/username and password fields
- Form validation
- Password visibility toggle
- Loading state during authentication
- Error message display
- Auto-redirect on success

### Home Screen
- Welcome message with user's display name
- Role-based menu:
  - **Admin Panel** (Admin only)
  - **Today's Tasks**
  - **Leaderboard**
- Logout button

### Today's Tasks Screen (Kid Mode)
- Large, touch-friendly task cards
- Visual status indicators (completed vs pending)
- Points display
- Verification badge for tasks requiring approval
- Tap to complete with confirmation dialog
- Real-time refresh
- Empty state when no tasks

### Leaderboard Screen
- Period selector (Week/Month/All Time)
- Ranked list with medal colors (gold/silver/bronze)
- Shows:
  - Rank
  - Display name
  - Total points
  - Tasks completed
- Empty state when no entries

### Admin Panel Screen
- Grid of admin functions:
  - **Users** - User management
  - **Task Definitions** - Create/edit task templates
  - **Verification Queue** - Approve/reject completed tasks
  - **Analytics** - View statistics

## Architecture

### Feature-Based Structure
```
lib/
├── core/                   # Cross-cutting concerns
│   ├── constants/         # App-wide constants
│   ├── network/           # HTTP client (Dio)
│   ├── router/            # Navigation (go_router)
│   ├── storage/           # Local storage (SharedPreferences)
│   └── theme/             # Theme configuration
├── features/              # Feature modules
│   ├── admin/
│   ├── auth/
│   ├── home/
│   ├── leaderboard/
│   ├── tasks/
│   └── today/
└── main.dart
```

Each feature has:
- `models/` - Data classes with Freezed
- `providers/` - Riverpod state management
- `repositories/` - API communication
- `screens/` - UI widgets

### State Management
- **Riverpod** with code generation (`riverpod_generator`)
- Async state handling with `AsyncValue`
- Automatic loading/error states
- Refresh capabilities

### API Integration
- Base URL: `http://localhost:8080/api`
- JWT Bearer authentication (auto-injected)
- Automatic 401 handling (logout and redirect)
- Dio for HTTP with interceptors

## Known Limitations

1. **No Flutter Installation**: Flutter SDK not currently installed, cannot run build_runner
2. **Generated Files Missing**: All `.g.dart` and `.freezed.dart` files need generation
3. **Admin Features**: Admin panel cards are placeholders (Users, Task Definitions, Verification Queue, Analytics)
4. **Error Handling**: Basic error handling implemented, could be enhanced
5. **Form Validation**: Only login screen has validation
6. **Loading States**: Basic spinners, could add skeleton screens
7. **Responsive Design**: Optimized for tablets, desktop/mobile need refinement

## Next Development Tasks

### Immediate (Required for App to Run)
1. ✅ Install Flutter SDK
2. ✅ Run `flutter pub get`
3. ✅ Run `flutter pub run build_runner build --delete-conflicting-outputs`
4. ✅ Test login flow
5. ✅ Verify backend connectivity

### Short Term (Core Features)
6. Implement User Management screen in Admin Panel
7. Implement Task Definition creation/editing in Admin Panel
8. Implement Verification Queue screen in Admin Panel
9. Add analytics/dashboard in Admin Panel
10. Add photo upload for task completions
11. Add notes field for task completions
12. Implement rewards system UI

### Medium Term (Enhancements)
13. Add form validation to all forms
14. Improve error handling with retry logic
15. Add skeleton loading screens
16. Implement pull-to-refresh
17. Add toast notifications for success/error
18. Improve responsive design for mobile
19. Add user profile screen
20. Add points history screen

### Long Term (Nice to Have)
21. Add charts with fl_chart (points over time, task completion rates)
22. Add animations and transitions
23. Add sound effects for task completion
24. Add avatar/profile pictures
25. Add dark mode support
26. Add internationalization (i18n)
27. Add unit and widget tests
28. Add integration tests

## Testing Checklist

Once build_runner completes:

- [ ] Login with admin credentials
- [ ] Navigate to Today's Tasks
- [ ] Complete a task
- [ ] Check if points update
- [ ] Navigate to Leaderboard
- [ ] Switch between Week/Month/All Time
- [ ] Navigate to Admin Panel (admin only)
- [ ] Logout and verify redirect to login
- [ ] Login with non-admin user
- [ ] Verify Admin Panel is hidden
- [ ] Test refresh buttons on all screens
- [ ] Test back navigation
- [ ] Verify error states (disconnect backend)
- [ ] Verify empty states (new user with no tasks)

## Troubleshooting

### "flutter: command not found"
- Install Flutter SDK from https://flutter.dev
- Add Flutter to PATH
- Run `flutter doctor` to verify

### "Could not find a command named 'pub'"
- Update Flutter: `flutter upgrade`
- Try: `flutter packages get` instead of `flutter pub get`

### "Target of URI doesn't exist"
- Run build_runner to generate missing files:
  ```bash
  flutter pub run build_runner build --delete-conflicting-outputs
  ```

### "DioException: Connection refused"
- Verify backend is running: `docker ps`
- Check API is accessible: open http://localhost:8080/swagger
- Verify no firewall blocking port 8080

### "401 Unauthorized"
- Check if JWT token is valid
- Try logging out and back in
- Verify backend authentication is working (test in Bruno/Postman)

### Build Runner Issues
- Clean generated files:
  ```bash
  flutter pub run build_runner clean
  ```
- Delete conflicting outputs:
  ```bash
  flutter pub run build_runner build --delete-conflicting-outputs
  ```
- Check for syntax errors in model files

## Support

For issues or questions:
1. Check console/browser developer tools for errors
2. Verify backend API is running and accessible
3. Check network tab in browser dev tools for API calls
4. Review Flutter logs: `flutter logs` (if running)
5. Check backend logs: `docker logs home-board-api`

## Summary

The frontend is **structurally complete** but needs:
1. ✅ Flutter SDK installation
2. ✅ Code generation via build_runner
3. ✅ Testing against backend API

After these steps, the core application will be functional with:
- ✅ Authentication flow
- ✅ Today's tasks (view and complete)
- ✅ Leaderboard (with period selection)
- ✅ Basic admin panel structure

The admin panel screens (user management, task creation, verification queue) are placeholders that need implementation as the next major feature development phase.
