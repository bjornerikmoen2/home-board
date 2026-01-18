# Scoreboard Feature - Implementation Plan

## Quick Access 🚀

**Scoreboard URL:** `http://localhost:3001/#/scoreboard` *(Note the `#` - hash routing is required!)*

**How to Access:**
1. Login to the app at `http://localhost:3001`
2. Click the "Scoreboard" menu item on the home screen
3. Or navigate directly to `http://localhost:3001/#/scoreboard` (no login required)

**Admin Toggle:** Admin → Settings → Enable Scoreboard

**Documentation:**
- Setup Guide: `docs/scoreboard-setup.md`
- Testing Guide: `docs/scoreboard-testing.md`

---

## Overview
Create a public scoreboard page that displays all users with their points and pending tasks for the current day. This page should be accessible without authentication at `/scoreboard`, but must be enabled via an admin setting.

## Requirements

### Functional Requirements
1. **Public Access**: The `/scoreboard` page should be accessible without login
2. **Admin Toggle**: Feature must be enabled in Admin → Settings page
3. **User Display**: Show all users with their current points
4. **Task Display**: For each user, show:
   - Tasks assigned specifically to that user (pending, due today)
   - Tasks assigned to "all users" (pending, due today)
   - Completed tasks should NOT be shown
5. **Sorting**: Users should be displayed (likely by points, descending - TBD)

### Non-Functional Requirements
- Page should be responsive and work well on different screen sizes
- Should respect dark mode settings (if applicable for public view)
- Should auto-refresh or have a refresh mechanism (TBD)

## Implementation Steps

### Step 1: Backend - Database Changes ✅
- [x] Add `EnableScoreboard` boolean field to `FamilySettings` entity
- [x] Create EF migration for the new field
- [x] Apply migration (Migration: 20260113142048_AddEnableScoreboardToFamilySettings - Applied)

### Step 2: Backend - Settings API ✅
- [x] Update `FamilySettingsModels.cs` to include `EnableScoreboard` property
- [x] Update `SettingsController.cs` GET endpoint to return the new setting
- [x] Update `SettingsController.cs` PATCH endpoint to accept and save the new setting
- [x] Add public `GET /api/settings/scoreboard-enabled` endpoint (no auth required)

### Step 3: Backend - Scoreboard API ✅
- [x] Create `ScoreboardModels.cs` with DTOs
  - `ScoreboardResponse` - contains list of user scoreboards
  - `UserScoreboard` - user info, points, and tasks
  - `ScoreboardTask` - task details for display (includes isAllUsersTask flag)
- [x] Create `ScoreboardController.cs` with GET endpoint:
  - Checks if scoreboard is enabled (returns 404 if not)
  - Fetches all active users sorted by points (descending)
  - Fetches pending tasks for today (user-specific + all-users tasks)
  - Filters out completed tasks for today
  - Maps to response DTOs
  - Uses `[AllowAnonymous]` for public access

### Step 4: Backend - Authentication Bypass ✅
- [x] Added `[AllowAnonymous]` attribute to scoreboard-enabled endpoint
- [x] Endpoint validates feature is enabled and returns boolean

### Step 5: Frontend - Settings Page ✅
- [x] Located the admin settings page/screen
- [x] Added "Enable Scoreboard" toggle/checkbox
- [x] Wired up to backend API to save/load the setting
- [x] Toggle works and persists to database

### Step 6: Frontend - Scoreboard Page ✅
- [x] Created `scoreboard_screen.dart` in features/scoreboard folder
- [x] Created `scoreboard_repository.dart` for API calls
- [x] Created `scoreboard_models.dart` for data models (with isAllUsersTask field)
- [x] Created `scoreboard_provider.dart` for state management
- [x] Implemented complete UI:
  - Shows "Scoreboard is disabled" message when feature is off
  - Displays all users in cards sorted by points
  - Shows user name with avatar (first letter)
  - Displays total points with gold coin icon and gold background
  - Lists pending tasks for each user
  - Task points displayed with gold coin icon
  - Differentiates between personal and "all users" tasks with icons
  - Shows "No pending tasks" message when user has no tasks
  - Handles loading and error states
  - Includes debug logging for troubleshooting
  - Responsive design with card-based layout
- [x] Implemented theme and language settings:
  - Backend includes admin user's PrefersDarkMode and PreferredLanguage in API response
  - Frontend automatically applies admin's theme (dark/light mode) when scoreboard loads
  - Frontend automatically applies admin's language preference when scoreboard loads
  - Settings applied without saving to backend (temporary for scoreboard view only)
  - All UI text is fully localized (English and Norwegian translations)
  - Localization strings: scoreboard, scoreboardDisabled, scoreboardDisabledMessage, noUsersFound, errorLoadingScoreboardData, errorLoadingScoreboard, noSharedTasks, allUsersTasks, noPendingTasks

### Step 7: Frontend - Routing ✅
- [x] Added `/scoreboard` route to app routing configuration
- [x] Ensured route is accessible without authentication
- [x] Added improved redirect logic to handle auth loading states
- [x] Tested navigation to the page (accessible at `http://localhost:3001/#/scoreboard`)
- [x] Added debug logging to router for troubleshooting

### Step 8: Frontend - Navigation ✅
- [x] Added scoreboard link to home screen navigation menu
- [x] Navigation shows for all users (feature toggle controls page content)

### Step 9: Testing
- [x] Test with scoreboard disabled (shows "disabled" message)
- [x] Test with scoreboard enabled (shows heading)
- [x] Test navigation via home screen menu
- [x] Test direct URL access (`http://localhost:3001/#/scoreboard`)
- [x] Test unauthenticated access (works without login)
- [x] Test admin toggle persists correctly
- [x] Test Bruno API endpoint for scoreboard-enabled
- [x] Test theme and language settings applied from admin user
- [ ] Test with multiple users (ready to test after rebuild)
- [ ] Test with users having no tasks (ready to test after rebuild)
- [ ] Test with tasks assigned to "all users" (ready to test after rebuild)
- [ ] Test with mix of pending and completed tasks (ready to test after rebuild)
- [ ] Test Bruno API endpoint for full scoreboard data
- [ ] Test points display accuracy
- [ ] Test task filtering (only pending tasks shown)
- [ ] Test dark mode changes when admin toggles their theme preference
- [ ] Test language changes when admin changes their language preference
- [ ] Test on mobile and desktop views

### Step 10: Documentation
- [x] Create Bruno API test file for scoreboard-enabled endpoint
- [x] Added rebuild scripts (rebuild-scoreboard.ps1, test-scoreboard.ps1)
- [ ] Update README.md with scoreboard feature information
- [ ] Update API documentation with scoreboard endpoints
- [ ] Document hash routing requirement for Flutter web

## Technical Considerations

### Security
- Since this is a public endpoint, ensure no sensitive data is exposed
- Validate that scoreboard is enabled before returning any data
- Consider rate limiting if needed

### Performance
- Consider caching if the page will be frequently accessed
- Optimize queries to avoid N+1 problems when fetching users and tasks

### UX Questions to Address
1. Should users be sorted by points (highest first)? *(To be decided when implementing data display)*
2. How should "all users" tasks be displayed? Under each user or in a separate section? *(To be decided)*
3. Should there be a refresh button or auto-refresh? *(To be decided)*
4. ✅ What should be shown if scoreboard is disabled but someone tries to access it? 
   - **Answer:** Show lock icon with message "Scoreboard is disabled" and instructions to contact admin
5. Should the page show a timestamp of when data was loaded? *(To be decided)*

## Current Status
**Phase 2 Complete:** Full scoreboard with data display is implemented! ✅
- Admin can toggle the feature on/off
- Public scoreboard page is accessible without authentication
- Backend API fetches all users with their points and pending tasks
- Frontend displays users in cards with:
  - User name and avatar
  - Total points with star icon
  - List of pending tasks (both personal and "all users" tasks)
  - Visual distinction between personal and group tasks
  - "No pending tasks" message when applicable
- Navigation integrated into home screen
- Comprehensive error handling and loading states

**Next Steps:** Testing and refinement
- Test with actual data (multiple users, various task scenarios)
- Consider adding refresh functionality
- Add timestamp of when data was loaded (optional)
- Polish UI and add animations (optional)

## Notes
- **Hash Routing:** Flutter web uses hash routing - URLs must include `#` (e.g., `http://localhost:3001/#/scoreboard`)
- **Public Access:** The scoreboard page is intentionally public and doesn't require authentication
- **Feature Toggle:** Content is controlled by the `EnableScoreboard` setting, not by route access
- **Debug Logging:** Added comprehensive logging in both router and scoreboard provider for troubleshooting
- Remember to test Bruno endpoints after backend changes
- Keep commits atomic and well-described
- Follow existing code patterns in the project

## Files Created/Modified

### Backend
- `HomeBoard.Domain/Entities/FamilySettings.cs` - Added `EnableScoreboard` property
- `HomeBoard.Infrastructure/Migrations/20260113142048_AddEnableScoreboardToFamilySettings.cs` - Migration
- `HomeBoard.Api/Models/FamilySettingsModels.cs` - Updated models
- `HomeBoard.Api/Models/ScoreboardModels.cs` - Created (ScoreboardResponse, UserScoreboard, ScoreboardTask) + Added AdminPrefersDarkMode and AdminPreferredLanguage
- `HomeBoard.Api/Controllers/SettingsController.cs` - Added public endpoint
- `HomeBoard.Api/Controllers/ScoreboardController.cs` - Created (GET /api/scoreboard with [AllowAnonymous]) + Fetches admin theme/language settings

### Frontend
- `lib/features/scoreboard/models/scoreboard_models.dart` - Created (with isAllUsersTask field) + Added adminPrefersDarkMode and adminPreferredLanguage
- `lib/features/scoreboard/repositories/scoreboard_repository.dart` - Created
- `lib/features/scoreboard/providers/scoreboard_provider.dart` - Created
- `lib/features/scoreboard/screens/scoreboard_screen.dart` - Created (complete UI with cards) + Applies admin theme and language settings
- `lib/core/router/app_router.dart` - Updated with scoreboard route and improved auth logic
- `lib/features/home/screens/home_screen.dart` - Added scoreboard navigation menu item


