class AppConstants {
  // API
  static const String apiBaseUrl = 'http://localhost:8080/api';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user';
  
  // Routes
  static const String loginRoute = '/login';
  static const String homeRoute = '/';
  static const String todayRoute = '/today';
  static const String adminRoute = '/admin';
  static const String leaderboardRoute = '/leaderboard';
  static const String profileRoute = '/profile';
  
  // Misc
  static const int maxRetries = 3;
}
