import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_nb.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('nb')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Home Board'**
  String get appTitle;

  /// Personalized title showing the user's name
  ///
  /// In en, this message translates to:
  /// **'{name}\'s Tasks'**
  String userTasksTitle(String name);

  /// Login button and screen title
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Logout button
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Username field label
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginButton;

  /// Validation message for username field
  ///
  /// In en, this message translates to:
  /// **'Please enter username'**
  String get usernameRequired;

  /// Validation message for password field
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get passwordRequired;

  /// Error message when login fails
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please check your credentials.'**
  String get loginFailed;

  /// Label for selecting no-password user
  ///
  /// In en, this message translates to:
  /// **'Select User'**
  String get selectUser;

  /// Separator between options
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// Title for today's tasks screen
  ///
  /// In en, this message translates to:
  /// **'Today\'s Tasks'**
  String get todayTasks;

  /// Heading for user's tasks
  ///
  /// In en, this message translates to:
  /// **'My Tasks for Today'**
  String get myTasksForToday;

  /// Message when there are no tasks
  ///
  /// In en, this message translates to:
  /// **'No tasks for today!'**
  String get noTasksToday;

  /// Encouraging message when no tasks
  ///
  /// In en, this message translates to:
  /// **'Enjoy your free time! 🎉'**
  String get enjoyFreeTime;

  /// Error message for task loading failure
  ///
  /// In en, this message translates to:
  /// **'Error loading tasks'**
  String get errorLoadingTasks;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Dialog title for completing a task
  ///
  /// In en, this message translates to:
  /// **'Complete Task'**
  String get completeTask;

  /// Confirmation message for completing a task
  ///
  /// In en, this message translates to:
  /// **'Mark \"{title}\" as complete?'**
  String markAsComplete(String title);

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Confirm button
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Home navigation item
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Today navigation item
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Leaderboard navigation item
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// Admin role
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// Tasks label
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// Points label
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// Users label
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// Settings label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Edit button
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Add button
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Loading indicator text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Generic error label
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Success message
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Task definitions screen title
  ///
  /// In en, this message translates to:
  /// **'Task Definitions'**
  String get taskDefinitions;

  /// Task assignments screen title
  ///
  /// In en, this message translates to:
  /// **'Task Assignments'**
  String get taskAssignments;

  /// Verification queue screen title
  ///
  /// In en, this message translates to:
  /// **'Verification Queue'**
  String get verificationQueue;

  /// User management screen title
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get userManagement;

  /// Payout screen title
  ///
  /// In en, this message translates to:
  /// **'Payout'**
  String get payout;

  /// Payout management screen title
  ///
  /// In en, this message translates to:
  /// **'Payout Management'**
  String get payoutManagement;

  /// Last payout date label
  ///
  /// In en, this message translates to:
  /// **'Last Payout'**
  String get lastPayout;

  /// Never label for last payout
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get never;

  /// Net points since last payout label
  ///
  /// In en, this message translates to:
  /// **'Net Points'**
  String get netPoints;

  /// Money to pay label
  ///
  /// In en, this message translates to:
  /// **'Money to Pay'**
  String get moneyToPay;

  /// Total money to pay label
  ///
  /// In en, this message translates to:
  /// **'Total to Pay'**
  String get totalToPay;

  /// Execute payout button
  ///
  /// In en, this message translates to:
  /// **'Execute Payout'**
  String get executePayout;

  /// Execute payout confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to execute payout for {count} user(s) totaling {amount}?'**
  String executePayoutConfirmation(int count, String amount);

  /// Payout executed success message
  ///
  /// In en, this message translates to:
  /// **'Payout executed successfully! Processed {count} user(s), paid out {amount}'**
  String payoutExecutedSuccessfully(int count, String amount);

  /// No users for payout message
  ///
  /// In en, this message translates to:
  /// **'No users have points to pay out'**
  String get noUsersForPayout;

  /// Select all checkbox label
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// Name field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Description field label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Status label
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// Role label
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// Parent role
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get parent;

  /// Child role
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get child;

  /// Welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// Points earned label
  ///
  /// In en, this message translates to:
  /// **'Points Earned'**
  String get pointsEarned;

  /// Task count label
  ///
  /// In en, this message translates to:
  /// **'Task Count'**
  String get taskCount;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Welcome message with user name
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}!'**
  String welcomeUser(String name);

  /// Admin panel title
  ///
  /// In en, this message translates to:
  /// **'Admin Panel'**
  String get adminPanel;

  /// Admin panel subtitle
  ///
  /// In en, this message translates to:
  /// **'Manage users, tasks, and verify completions'**
  String get adminPanelSubtitle;

  /// Today's tasks menu title
  ///
  /// In en, this message translates to:
  /// **'Today\'s Tasks'**
  String get todayTasksTitle;

  /// Today's tasks subtitle
  ///
  /// In en, this message translates to:
  /// **'View and complete your tasks for today'**
  String get todayTasksSubtitle;

  /// Leaderboard menu title
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboardTitle;

  /// Leaderboard subtitle
  ///
  /// In en, this message translates to:
  /// **'See who\'s leading in points'**
  String get leaderboardSubtitle;

  /// Admin dashboard heading
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboard;

  /// Analytics screen title
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// Refresh button
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// Complete button text
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// Completed status label
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// Success message for tasks requiring verification
  ///
  /// In en, this message translates to:
  /// **'Task completed! Waiting for verification.'**
  String get taskCompletedVerification;

  /// Success message with points earned
  ///
  /// In en, this message translates to:
  /// **'Task completed! +{points} points'**
  String taskCompletedPoints(int points);

  /// Points value display
  ///
  /// In en, this message translates to:
  /// **'{points} points'**
  String pointsValue(int points);

  /// Label for tasks requiring verification
  ///
  /// In en, this message translates to:
  /// **'Needs verification'**
  String get needsVerification;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorMessage(String error);

  /// Add user button
  ///
  /// In en, this message translates to:
  /// **'Add User'**
  String get addUser;

  /// Message when no users exist
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noUsersFound;

  /// Reset password button
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// Reset points button
  ///
  /// In en, this message translates to:
  /// **'Reset Points'**
  String get resetPoints;

  /// Reset points dialog title
  ///
  /// In en, this message translates to:
  /// **'Reset Points for {name}'**
  String resetPointsFor(String name);

  /// Confirmation message for resetting points
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all points for \"{name}\"? This will set their total points to zero. This action cannot be undone.'**
  String resetPointsConfirmation(String name);

  /// Success message after resetting points
  ///
  /// In en, this message translates to:
  /// **'Points reset successfully'**
  String get pointsResetSuccessfully;

  /// Bonus points menu item
  ///
  /// In en, this message translates to:
  /// **'Bonus Points'**
  String get bonusPoints;

  /// Bonus points dialog title
  ///
  /// In en, this message translates to:
  /// **'Award Bonus Points to {name}'**
  String bonusPointsFor(String name);

  /// Success message after awarding bonus points
  ///
  /// In en, this message translates to:
  /// **'Bonus points awarded successfully'**
  String get bonusPointsAwarded;

  /// Error message for invalid points input
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number of points (greater than 0)'**
  String get pleaseEnterValidPoints;

  /// Award button text
  ///
  /// In en, this message translates to:
  /// **'Award'**
  String get award;

  /// Optional field indicator
  ///
  /// In en, this message translates to:
  /// **'optional'**
  String get optional;

  /// Label for no password required checkbox
  ///
  /// In en, this message translates to:
  /// **'No password required'**
  String get noPasswordRequired;

  /// Description for no password required checkbox
  ///
  /// In en, this message translates to:
  /// **'Allow login without entering a password (for kids)'**
  String get noPasswordRequiredDescription;

  /// Create user dialog title
  ///
  /// In en, this message translates to:
  /// **'Create New User'**
  String get createNewUser;

  /// Display name field label
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// User role
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// Create button
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Success message after creating user
  ///
  /// In en, this message translates to:
  /// **'User created successfully'**
  String get userCreatedSuccessfully;

  /// Edit user dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit User'**
  String get editUser;

  /// Success message after updating user
  ///
  /// In en, this message translates to:
  /// **'User updated successfully'**
  String get userUpdatedSuccessfully;

  /// Reset password dialog title
  ///
  /// In en, this message translates to:
  /// **'Reset Password for {name}'**
  String resetPasswordFor(String name);

  /// New password field label
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// Success message after resetting password
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully'**
  String get passwordResetSuccessfully;

  /// Delete user dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete User'**
  String get deleteUser;

  /// Delete user confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String deleteUserConfirmation(String name);

  /// Success message after deleting user
  ///
  /// In en, this message translates to:
  /// **'User deleted successfully'**
  String get userDeletedSuccessfully;

  /// Leaderboard heading
  ///
  /// In en, this message translates to:
  /// **'Top Performers'**
  String get topPerformers;

  /// Week time period
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// This week period label
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// Previous week period label
  ///
  /// In en, this message translates to:
  /// **'Previous Week'**
  String get previousWeek;

  /// Month time period
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// All time period
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// Message when leaderboard is empty
  ///
  /// In en, this message translates to:
  /// **'No entries yet'**
  String get noEntriesYet;

  /// Encouraging message for empty leaderboard
  ///
  /// In en, this message translates to:
  /// **'Complete tasks to appear here!'**
  String get completeTasksToAppear;

  /// Rank label
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get rank;

  /// Tasks completed label
  ///
  /// In en, this message translates to:
  /// **'{count} tasks completed'**
  String tasksCompleted(int count);

  /// Add task button
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get addTask;

  /// Message when no tasks exist
  ///
  /// In en, this message translates to:
  /// **'No tasks found'**
  String get noTasksFound;

  /// Message when no task definitions exist
  ///
  /// In en, this message translates to:
  /// **'No task definitions'**
  String get noTaskDefinitions;

  /// Encouraging message to create first task
  ///
  /// In en, this message translates to:
  /// **'Create your first task template!'**
  String get createFirstTask;

  /// Error message for missing title
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get titleRequired;

  /// Error message for invalid points
  ///
  /// In en, this message translates to:
  /// **'Points must be a positive number'**
  String get pointsPositiveNumber;

  /// Warning message when deleting task definition
  ///
  /// In en, this message translates to:
  /// **'This will mark it as inactive. Existing assignments will remain.'**
  String get deleteTaskWarning;

  /// Inactive status
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// Active status
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// Assign button
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get assign;

  /// Create task definition dialog title
  ///
  /// In en, this message translates to:
  /// **'Create Task Definition'**
  String get createTaskDefinition;

  /// Title field label
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// Success message after creating task
  ///
  /// In en, this message translates to:
  /// **'Task created successfully'**
  String get taskCreatedSuccessfully;

  /// Edit task definition dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit Task Definition'**
  String get editTaskDefinition;

  /// Active task description
  ///
  /// In en, this message translates to:
  /// **'Task can be assigned to users'**
  String get taskCanBeAssigned;

  /// Success message after updating task
  ///
  /// In en, this message translates to:
  /// **'Task updated successfully'**
  String get taskUpdatedSuccessfully;

  /// Delete task definition dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Task Definition'**
  String get deleteTaskDefinition;

  /// Delete task confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"?'**
  String deleteTaskConfirmation(String title);

  /// Success message after deleting task
  ///
  /// In en, this message translates to:
  /// **'Task deleted successfully'**
  String get taskDeletedSuccessfully;

  /// New assignment button
  ///
  /// In en, this message translates to:
  /// **'New Assignment'**
  String get newAssignment;

  /// Message when no assignments exist
  ///
  /// In en, this message translates to:
  /// **'No assignments found'**
  String get noAssignmentsFound;

  /// Message when no assignments exist
  ///
  /// In en, this message translates to:
  /// **'No task assignments yet'**
  String get noAssignmentsYet;

  /// Encouraging message to create first assignment
  ///
  /// In en, this message translates to:
  /// **'Create an assignment to get started'**
  String get createAssignmentToStart;

  /// Schedule type label
  ///
  /// In en, this message translates to:
  /// **'Schedule Type'**
  String get scheduleType;

  /// Days of week label
  ///
  /// In en, this message translates to:
  /// **'Days of Week'**
  String get daysOfWeek;

  /// Start date field label
  ///
  /// In en, this message translates to:
  /// **'Start Date (Optional)'**
  String get startDateOptional;

  /// End date field label
  ///
  /// In en, this message translates to:
  /// **'End Date (Optional)'**
  String get endDateOptional;

  /// Due time field label
  ///
  /// In en, this message translates to:
  /// **'Due Time (Optional)'**
  String get dueTimeOptional;

  /// Update button
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// Sunday short name
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sun;

  /// Monday short name
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mon;

  /// Tuesday short name
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tue;

  /// Wednesday short name
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wed;

  /// Thursday short name
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thu;

  /// Friday short name
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fri;

  /// Saturday short name
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get sat;

  /// Unknown status
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// Delete assignment confirmation
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the assignment \"{task}\" for {user}?'**
  String deleteAssignmentQuestion(String task, String user);

  /// Assignment label
  ///
  /// In en, this message translates to:
  /// **'Assigned to: {name}'**
  String assignedTo(String name);

  /// Due time label
  ///
  /// In en, this message translates to:
  /// **'Due: {time}'**
  String due(String time);

  /// Message when no task definitions exist
  ///
  /// In en, this message translates to:
  /// **'No task definitions available. Create one first.'**
  String get noTaskDefinitionsAvailable;

  /// Message when no users exist
  ///
  /// In en, this message translates to:
  /// **'No users available. Create a user first.'**
  String get noUsersAvailable;

  /// Create assignment dialog title
  ///
  /// In en, this message translates to:
  /// **'Create Task Assignment'**
  String get createTaskAssignment;

  /// Task label
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get task;

  /// Assign to field label
  ///
  /// In en, this message translates to:
  /// **'Assign To'**
  String get assignTo;

  /// Daily schedule type
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// Weekly schedule type
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// Once schedule type
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get once;

  /// During week schedule type - task must be completed sometime during the week
  ///
  /// In en, this message translates to:
  /// **'During Week'**
  String get duringWeek;

  /// During month schedule type - task must be completed sometime during the month
  ///
  /// In en, this message translates to:
  /// **'During Month'**
  String get duringMonth;

  /// Select days heading
  ///
  /// In en, this message translates to:
  /// **'Select Days'**
  String get selectDays;

  /// Monday day name
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// Tuesday day name
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// Wednesday day name
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// Thursday day name
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// Friday day name
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// Saturday day name
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// Sunday day name
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// Due time field label
  ///
  /// In en, this message translates to:
  /// **'Due Time'**
  String get dueTime;

  /// Success message after creating assignment
  ///
  /// In en, this message translates to:
  /// **'Assignment created successfully'**
  String get assignmentCreatedSuccessfully;

  /// Edit assignment dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit Assignment'**
  String get editAssignment;

  /// Success message after updating assignment
  ///
  /// In en, this message translates to:
  /// **'Assignment updated successfully'**
  String get assignmentUpdatedSuccessfully;

  /// Delete assignment dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Assignment'**
  String get deleteAssignment;

  /// Delete assignment confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this assignment?'**
  String get deleteAssignmentConfirmation;

  /// Success message after deleting assignment
  ///
  /// In en, this message translates to:
  /// **'Assignment deleted successfully'**
  String get assignmentDeletedSuccessfully;

  /// Pending verification heading
  ///
  /// In en, this message translates to:
  /// **'Pending Verification'**
  String get pendingVerification;

  /// Message when verification queue is empty
  ///
  /// In en, this message translates to:
  /// **'No items in queue'**
  String get noItemsInQueue;

  /// Message when all verifications are complete
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up!'**
  String get allCaughtUp;

  /// Completed by label
  ///
  /// In en, this message translates to:
  /// **'Completed by {name}'**
  String completedBy(String name);

  /// Completed at label
  ///
  /// In en, this message translates to:
  /// **'Completed at: {time}'**
  String completedAt(String time);

  /// Error message when image fails to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load image'**
  String get failedToLoadImage;

  /// Button to verify and award points
  ///
  /// In en, this message translates to:
  /// **'Verify & Award Points'**
  String get verifyAndAwardPoints;

  /// Reject button
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// Dialog title for verifying a task
  ///
  /// In en, this message translates to:
  /// **'Verify Task'**
  String get verifyTask;

  /// Verify task confirmation message
  ///
  /// In en, this message translates to:
  /// **'Award {points} points to {name}?'**
  String verifyTaskConfirmation(int points, String name);

  /// Verify button
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// Success message after verifying task
  ///
  /// In en, this message translates to:
  /// **'Task verified! {points} points awarded to {name}'**
  String taskVerifiedPoints(int points, String name);

  /// Dialog title for rejecting a task
  ///
  /// In en, this message translates to:
  /// **'Reject Task'**
  String get rejectTask;

  /// Confirmation message for rejecting task
  ///
  /// In en, this message translates to:
  /// **'Reject \"{taskTitle}\" by {userName}?'**
  String rejectTaskConfirmation(String taskTitle, String userName);

  /// Success message after rejecting task
  ///
  /// In en, this message translates to:
  /// **'Task rejected'**
  String get taskRejected;

  /// Calendar screen title
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// Calendar menu subtitle
  ///
  /// In en, this message translates to:
  /// **'View upcoming tasks and schedules'**
  String get calendarSubtitle;

  /// Message showing additional task count
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String moreTasksCount(int count);

  /// Timezone setting label
  ///
  /// In en, this message translates to:
  /// **'Timezone'**
  String get timezone;

  /// Change timezone dialog title
  ///
  /// In en, this message translates to:
  /// **'Change Timezone'**
  String get changeTimezone;

  /// Timezone input hint
  ///
  /// In en, this message translates to:
  /// **'e.g., Europe/Oslo, America/New_York'**
  String get timezoneHint;

  /// Timezone input helper text
  ///
  /// In en, this message translates to:
  /// **'IANA timezone identifier'**
  String get timezoneHelper;

  /// Point to money rate setting label
  ///
  /// In en, this message translates to:
  /// **'Point to Money Rate'**
  String get pointToMoneyRate;

  /// Change point to money rate dialog title
  ///
  /// In en, this message translates to:
  /// **'Change Point to Money Rate'**
  String get changePointToMoneyRate;

  /// Rate field label
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rate;

  /// Rate input hint
  ///
  /// In en, this message translates to:
  /// **'e.g., 1.0, 0.5, 0.10'**
  String get rateHint;

  /// Rate input helper text
  ///
  /// In en, this message translates to:
  /// **'Currency value per point'**
  String get rateHelper;

  /// Currency per point display
  ///
  /// In en, this message translates to:
  /// **'{amount} currency per point'**
  String currencyPerPoint(String amount);

  /// Week starts on setting label
  ///
  /// In en, this message translates to:
  /// **'Week Starts On'**
  String get weekStartsOn;

  /// Analytics menu subtitle
  ///
  /// In en, this message translates to:
  /// **'View completion rates and points statistics'**
  String get analyticsSubtitle;

  /// Time period selector label
  ///
  /// In en, this message translates to:
  /// **'Time Period:'**
  String get timePeriod;

  /// Number of days label
  ///
  /// In en, this message translates to:
  /// **'{count} Days'**
  String days(int count);

  /// Points summary card title
  ///
  /// In en, this message translates to:
  /// **'Points Summary'**
  String get pointsSummary;

  /// Total points earned label
  ///
  /// In en, this message translates to:
  /// **'Total Earned'**
  String get totalEarned;

  /// Total money paid out label
  ///
  /// In en, this message translates to:
  /// **'Total Paid Out'**
  String get totalPaidOut;

  /// Current points balance label
  ///
  /// In en, this message translates to:
  /// **'Current Balance'**
  String get currentBalance;

  /// Completion rates card title
  ///
  /// In en, this message translates to:
  /// **'Completion Rates'**
  String get completionRates;

  /// Average label
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// Points chart card title
  ///
  /// In en, this message translates to:
  /// **'Points earned vs money paid out'**
  String get pointsEarnedVsMoneyPaidOut;

  /// Earned legend label
  ///
  /// In en, this message translates to:
  /// **'Earned'**
  String get earned;

  /// Paid out legend label
  ///
  /// In en, this message translates to:
  /// **'Paid Out'**
  String get paidOut;

  /// Redeemed legend label
  ///
  /// In en, this message translates to:
  /// **'Redeemed'**
  String get redeemed;

  /// No data message
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// Title for pending task verifications section
  ///
  /// In en, this message translates to:
  /// **'Pending Task Verifications'**
  String get pendingTaskVerifications;

  /// Message when no tasks need verification
  ///
  /// In en, this message translates to:
  /// **'No tasks pending verification'**
  String get noTasksPendingVerification;

  /// Message when all task completions are reviewed
  ///
  /// In en, this message translates to:
  /// **'All task completions have been reviewed'**
  String get allTaskCompletionsReviewed;

  /// Shows who completed the task
  ///
  /// In en, this message translates to:
  /// **'Completed by: {userName}'**
  String completedByUser(String userName);

  /// Label for notes section
  ///
  /// In en, this message translates to:
  /// **'Notes:'**
  String get notes;

  /// Confirmation message for awarding points
  ///
  /// In en, this message translates to:
  /// **'Award {points} points to {userName} for completing \"{taskTitle}\"?'**
  String awardPointsConfirmation(int points, String userName, String taskTitle);

  /// Success message after verifying task
  ///
  /// In en, this message translates to:
  /// **'Task verified! {points} points awarded to {userName}'**
  String taskVerifiedPointsAwarded(int points, String userName);

  /// Label for optional reason field
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get reasonOptional;

  /// Hint text for rejection reason
  ///
  /// In en, this message translates to:
  /// **'Why is this task being rejected?'**
  String get whyTaskRejected;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'nb'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'nb': return AppLocalizationsNb();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
