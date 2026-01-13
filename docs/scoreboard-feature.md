# Scoreboard Feature - Implementation Plan

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

### Step 3: Backend - Scoreboard API
- [ ] Create `ScoreboardModels.cs` with DTOs:
  - `ScoreboardResponse` - contains list of user scoreboards
  - `UserScoreboard` - user info, points, and tasks
  - `ScoreboardTask` - task details for display
- [ ] Create `ScoreboardController.cs` with GET endpoint:
  - Check if scoreboard is enabled (return 404 or 403 if not)
  - Fetch all users with their current points
  - Fetch pending tasks for today (user-specific + all-users tasks)
  - Map to response DTOs
  - **Important**: This endpoint should NOT require authentication

### Step 4: Backend - Authentication Bypass
- [ ] Update `Program.cs` or auth middleware to allow unauthenticated access to `/api/scoreboard` endpoint
- [ ] Ensure the endpoint still validates that the feature is enabled

### Step 5: Frontend - Settings Page
- [ ] Locate the admin settings page/screen
- [ ] Add "Enable Scoreboard" toggle/checkbox
- [ ] Wire up to backend API to save/load the setting

### Step 6: Frontend - Scoreboard Page
- [ ] Create `scoreboard_screen.dart` in appropriate features folder
- [ ] Create `scoreboard_service.dart` for API calls
- [ ] Create `scoreboard_models.dart` for data models
- [ ] Implement UI:
  - Display users in cards/list
  - Show points prominently for each user
  - Show pending tasks under each user
  - Handle "all users" tasks appropriately
  - Show appropriate message when no tasks exist
  - Handle loading and error states

### Step 7: Frontend - Routing
- [ ] Add `/scoreboard` route to app routing configuration
- [ ] Ensure route is accessible without authentication
- [ ] Test navigation to the page

### Step 8: Frontend - Navigation (Optional)
- [ ] Decide if scoreboard link should appear in navigation menu
- [ ] If yes, add conditional link (only show if enabled)

### Step 9: Testing
- [ ] Test with scoreboard disabled (should not be accessible)
- [ ] Test with scoreboard enabled
- [ ] Test with multiple users
- [ ] Test with users having no tasks
- [ ] Test with tasks assigned to "all users"
- [ ] Test with mix of pending and completed tasks
- [ ] Test in both light and dark mode
- [ ] Test on mobile and desktop views
- [ ] Test Bruno API endpoints

### Step 10: Documentation
- [ ] Update README.md with scoreboard feature information
- [ ] Create Bruno API test files for scoreboard endpoints
- [ ] Update API documentation

## Technical Considerations

### Security
- Since this is a public endpoint, ensure no sensitive data is exposed
- Validate that scoreboard is enabled before returning any data
- Consider rate limiting if needed

### Performance
- Consider caching if the page will be frequently accessed
- Optimize queries to avoid N+1 problems when fetching users and tasks

### UX Questions to Address
1. Should users be sorted by points (highest first)?
2. How should "all users" tasks be displayed? Under each user or in a separate section?
3. Should there be a refresh button or auto-refresh?
4. What should be shown if scoreboard is disabled but someone tries to access it?
5. Should the page show a timestamp of when data was loaded?

## Current Status
- [ ] Not started
- Current branch: `feature/scoreboard`

## Notes
- Remember to test Bruno endpoints after backend changes
- Keep commits atomic and well-described
- Follow existing code patterns in the project

