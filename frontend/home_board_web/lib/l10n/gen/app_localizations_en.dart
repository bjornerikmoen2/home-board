// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Home Board';

  @override
  String userTasksTitle(String name) {
    return '$name\'s Tasks';
  }

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get loginButton => 'Sign In';

  @override
  String get usernameRequired => 'Please enter username';

  @override
  String get passwordRequired => 'Please enter password';

  @override
  String get loginFailed => 'Login failed. Please check your credentials.';

  @override
  String get selectUser => 'Select User';

  @override
  String get or => 'OR';

  @override
  String get todayTasks => 'Today\'s Tasks';

  @override
  String get myTasksForToday => 'My Tasks for Today';

  @override
  String get noTasksToday => 'No tasks for today!';

  @override
  String get enjoyFreeTime => 'Enjoy your free time! 🎉';

  @override
  String get errorLoadingTasks => 'Error loading tasks';

  @override
  String get retry => 'Retry';

  @override
  String get completeTask => 'Complete Task';

  @override
  String markAsComplete(String title) {
    return 'Mark \"$title\" as complete?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get home => 'Home';

  @override
  String get today => 'Today';

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get admin => 'Admin';

  @override
  String get tasks => 'Tasks';

  @override
  String get points => 'Points';

  @override
  String get users => 'Users';

  @override
  String get settings => 'Settings';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get taskDefinitions => 'Task Definitions';

  @override
  String get taskAssignments => 'Task Assignments';

  @override
  String get verificationQueue => 'Verification Queue';

  @override
  String get userManagement => 'User Management';

  @override
  String get payout => 'Payout';

  @override
  String get payoutManagement => 'Payout Management';

  @override
  String get lastPayout => 'Last Payout';

  @override
  String get never => 'Never';

  @override
  String get netPoints => 'Net Points';

  @override
  String get moneyToPay => 'Money to Pay';

  @override
  String get totalToPay => 'Total to Pay';

  @override
  String get executePayout => 'Execute Payout';

  @override
  String executePayoutConfirmation(int count, String amount) {
    return 'Are you sure you want to execute payout for $count user(s) totaling $amount?';
  }

  @override
  String payoutExecutedSuccessfully(int count, String amount) {
    return 'Payout executed successfully! Processed $count user(s), paid out $amount';
  }

  @override
  String get noUsersForPayout => 'No users have points to pay out';

  @override
  String get selectAll => 'Select All';

  @override
  String get name => 'Name';

  @override
  String get description => 'Description';

  @override
  String get status => 'Status';

  @override
  String get role => 'Role';

  @override
  String get parent => 'Parent';

  @override
  String get child => 'Child';

  @override
  String get welcome => 'Welcome';

  @override
  String get pointsEarned => 'Points Earned';

  @override
  String get taskCount => 'Task Count';

  @override
  String get language => 'Language';

  @override
  String welcomeUser(String name) {
    return 'Welcome, $name!';
  }

  @override
  String get adminPanel => 'Admin Panel';

  @override
  String get adminPanelSubtitle => 'Manage users, tasks, and verify completions';

  @override
  String get todayTasksTitle => 'Today\'s Tasks';

  @override
  String get todayTasksSubtitle => 'View and complete your tasks for today';

  @override
  String get leaderboardTitle => 'Leaderboard';

  @override
  String get leaderboardSubtitle => 'See who\'s leading in points';

  @override
  String get adminDashboard => 'Admin Dashboard';

  @override
  String get analytics => 'Analytics';

  @override
  String get refresh => 'Refresh';

  @override
  String get complete => 'Complete';

  @override
  String get completed => 'Completed';

  @override
  String get taskCompletedVerification => 'Task completed! Waiting for verification.';

  @override
  String taskCompletedPoints(int points) {
    return 'Task completed! +$points points';
  }

  @override
  String pointsValue(int points) {
    return '$points points';
  }

  @override
  String get needsVerification => 'Needs verification';

  @override
  String errorMessage(String error) {
    return 'Error: $error';
  }

  @override
  String get addUser => 'Add User';

  @override
  String get noUsersFound => 'No users found';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetPoints => 'Reset Points';

  @override
  String resetPointsFor(String name) {
    return 'Reset Points for $name';
  }

  @override
  String resetPointsConfirmation(String name) {
    return 'Are you sure you want to reset all points for \"$name\"? This will set their total points to zero. This action cannot be undone.';
  }

  @override
  String get pointsResetSuccessfully => 'Points reset successfully';

  @override
  String get bonusPoints => 'Bonus Points';

  @override
  String bonusPointsFor(String name) {
    return 'Award Bonus Points to $name';
  }

  @override
  String get bonusPointsAwarded => 'Bonus points awarded successfully';

  @override
  String get pleaseEnterValidPoints => 'Please enter a valid number of points (greater than 0)';

  @override
  String get award => 'Award';

  @override
  String get optional => 'optional';

  @override
  String get noPasswordRequired => 'No password required';

  @override
  String get noPasswordRequiredDescription => 'Allow login without entering a password (for kids)';

  @override
  String get createNewUser => 'Create New User';

  @override
  String get displayName => 'Display Name';

  @override
  String get user => 'User';

  @override
  String get create => 'Create';

  @override
  String get userCreatedSuccessfully => 'User created successfully';

  @override
  String get editUser => 'Edit User';

  @override
  String get userUpdatedSuccessfully => 'User updated successfully';

  @override
  String resetPasswordFor(String name) {
    return 'Reset Password for $name';
  }

  @override
  String get newPassword => 'New Password';

  @override
  String get passwordResetSuccessfully => 'Password reset successfully';

  @override
  String get deleteUser => 'Delete User';

  @override
  String deleteUserConfirmation(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get userDeletedSuccessfully => 'User deleted successfully';

  @override
  String get topPerformers => 'Top Performers';

  @override
  String get week => 'Week';

  @override
  String get thisWeek => 'This Week';

  @override
  String get previousWeek => 'Previous Week';

  @override
  String get month => 'Month';

  @override
  String get allTime => 'All Time';

  @override
  String get noEntriesYet => 'No entries yet';

  @override
  String get completeTasksToAppear => 'Complete tasks to appear here!';

  @override
  String get rank => 'Rank';

  @override
  String tasksCompleted(int count) {
    return '$count tasks completed';
  }

  @override
  String get addTask => 'Add Task';

  @override
  String get noTasksFound => 'No tasks found';

  @override
  String get noTaskDefinitions => 'No task definitions';

  @override
  String get createFirstTask => 'Create your first task template!';

  @override
  String get titleRequired => 'Title is required';

  @override
  String get pointsPositiveNumber => 'Points must be a positive number';

  @override
  String get deleteTaskWarning => 'This will mark it as inactive. Existing assignments will remain.';

  @override
  String get inactive => 'Inactive';

  @override
  String get active => 'Active';

  @override
  String get assign => 'Assign';

  @override
  String get createTaskDefinition => 'Create Task Definition';

  @override
  String get title => 'Title';

  @override
  String get taskCreatedSuccessfully => 'Task created successfully';

  @override
  String get editTaskDefinition => 'Edit Task Definition';

  @override
  String get taskCanBeAssigned => 'Task can be assigned to users';

  @override
  String get taskUpdatedSuccessfully => 'Task updated successfully';

  @override
  String get deleteTaskDefinition => 'Delete Task Definition';

  @override
  String deleteTaskConfirmation(String title) {
    return 'Are you sure you want to delete \"$title\"?';
  }

  @override
  String get taskDeletedSuccessfully => 'Task deleted successfully';

  @override
  String get newAssignment => 'New Assignment';

  @override
  String get noAssignmentsFound => 'No assignments found';

  @override
  String get noAssignmentsYet => 'No task assignments yet';

  @override
  String get createAssignmentToStart => 'Create an assignment to get started';

  @override
  String get scheduleType => 'Schedule Type';

  @override
  String get daysOfWeek => 'Days of Week';

  @override
  String get startDateOptional => 'Start Date (Optional)';

  @override
  String get endDateOptional => 'End Date (Optional)';

  @override
  String get dueTimeOptional => 'Due Time (Optional)';

  @override
  String get update => 'Update';

  @override
  String get sun => 'Sun';

  @override
  String get mon => 'Mon';

  @override
  String get tue => 'Tue';

  @override
  String get wed => 'Wed';

  @override
  String get thu => 'Thu';

  @override
  String get fri => 'Fri';

  @override
  String get sat => 'Sat';

  @override
  String get unknown => 'Unknown';

  @override
  String deleteAssignmentQuestion(String task, String user) {
    return 'Are you sure you want to delete the assignment \"$task\" for $user?';
  }

  @override
  String assignedTo(String name) {
    return 'Assigned to: $name';
  }

  @override
  String due(String time) {
    return 'Due: $time';
  }

  @override
  String get noTaskDefinitionsAvailable => 'No task definitions available. Create one first.';

  @override
  String get noUsersAvailable => 'No users available. Create a user first.';

  @override
  String get createTaskAssignment => 'Create Task Assignment';

  @override
  String get task => 'Task';

  @override
  String get assignTo => 'Assign To';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get once => 'Once';

  @override
  String get duringWeek => 'During Week';

  @override
  String get duringMonth => 'During Month';

  @override
  String get selectDays => 'Select Days';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get dueTime => 'Due Time';

  @override
  String get assignmentCreatedSuccessfully => 'Assignment created successfully';

  @override
  String get editAssignment => 'Edit Assignment';

  @override
  String get assignmentUpdatedSuccessfully => 'Assignment updated successfully';

  @override
  String get deleteAssignment => 'Delete Assignment';

  @override
  String get deleteAssignmentConfirmation => 'Are you sure you want to delete this assignment?';

  @override
  String get assignmentDeletedSuccessfully => 'Assignment deleted successfully';

  @override
  String get pendingVerification => 'Pending Verification';

  @override
  String get noItemsInQueue => 'No items in queue';

  @override
  String get allCaughtUp => 'You\'re all caught up!';

  @override
  String completedBy(String name) {
    return 'Completed by $name';
  }

  @override
  String completedAt(String time) {
    return 'Completed at: $time';
  }

  @override
  String get failedToLoadImage => 'Failed to load image';

  @override
  String get verifyAndAwardPoints => 'Verify & Award Points';

  @override
  String get reject => 'Reject';

  @override
  String get verifyTask => 'Verify Task';

  @override
  String verifyTaskConfirmation(int points, String name) {
    return 'Award $points points to $name?';
  }

  @override
  String get verify => 'Verify';

  @override
  String taskVerifiedPoints(int points, String name) {
    return 'Task verified! $points points awarded to $name';
  }

  @override
  String get rejectTask => 'Reject Task';

  @override
  String rejectTaskConfirmation(String taskTitle, String userName) {
    return 'Reject \"$taskTitle\" by $userName?';
  }

  @override
  String get taskRejected => 'Task rejected';

  @override
  String get calendar => 'Calendar';

  @override
  String get calendarSubtitle => 'View upcoming tasks and schedules';

  @override
  String moreTasksCount(int count) {
    return '+$count more';
  }

  @override
  String get timezone => 'Timezone';

  @override
  String get changeTimezone => 'Change Timezone';

  @override
  String get timezoneHint => 'e.g., Europe/Oslo, America/New_York';

  @override
  String get timezoneHelper => 'IANA timezone identifier';

  @override
  String get pointToMoneyRate => 'Point to Money Rate';

  @override
  String get changePointToMoneyRate => 'Change Point to Money Rate';

  @override
  String get rate => 'Rate';

  @override
  String get rateHint => 'e.g., 1.0, 0.5, 0.10';

  @override
  String get rateHelper => 'Currency value per point';

  @override
  String currencyPerPoint(String amount) {
    return '$amount currency per point';
  }

  @override
  String get weekStartsOn => 'Week Starts On';

  @override
  String get analyticsSubtitle => 'View completion rates and points statistics';

  @override
  String get timePeriod => 'Time Period:';

  @override
  String days(int count) {
    return '$count Days';
  }

  @override
  String get pointsSummary => 'Points Summary';

  @override
  String get totalEarned => 'Total Earned';

  @override
  String get totalPaidOut => 'Total Paid Out';

  @override
  String get currentBalance => 'Current Balance';

  @override
  String get completionRates => 'Completion Rates';

  @override
  String get average => 'Average';

  @override
  String get pointsEarnedVsMoneyPaidOut => 'Points earned vs money paid out';

  @override
  String get earned => 'Earned';

  @override
  String get paidOut => 'Paid Out';

  @override
  String get redeemed => 'Redeemed';

  @override
  String get noData => 'No data available';

  @override
  String get pendingTaskVerifications => 'Pending Task Verifications';

  @override
  String get noTasksPendingVerification => 'No tasks pending verification';

  @override
  String get allTaskCompletionsReviewed => 'All task completions have been reviewed';

  @override
  String completedByUser(String userName) {
    return 'Completed by: $userName';
  }

  @override
  String get notes => 'Notes:';

  @override
  String awardPointsConfirmation(int points, String userName, String taskTitle) {
    return 'Award $points points to $userName for completing \"$taskTitle\"?';
  }

  @override
  String taskVerifiedPointsAwarded(int points, String userName) {
    return 'Task verified! $points points awarded to $userName';
  }

  @override
  String get reasonOptional => 'Reason (optional)';

  @override
  String get whyTaskRejected => 'Why is this task being rejected?';
}
