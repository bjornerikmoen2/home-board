import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/scoreboard_models.dart';
import '../providers/scoreboard_provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../../l10n/gen/app_localizations.dart';

class ScoreboardScreen extends ConsumerStatefulWidget {
  const ScoreboardScreen({super.key});

  @override
  ConsumerState<ScoreboardScreen> createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends ConsumerState<ScoreboardScreen> {
  DateTime? _lastRefreshTime;

  @override
  void initState() {
    super.initState();
    _lastRefreshTime = DateTime.now();
  }

  void _refreshScoreboard() {
    setState(() {
      _lastRefreshTime = DateTime.now();
    });
    ref.read(autoRefreshProvider.notifier).manualRefresh();
  }

  @override
  Widget build(BuildContext context) {
    // Debug: This screen is being rendered
    if (kDebugMode) {
      print('ScoreboardScreen is being built');
    }

    final isEnabledAsync = ref.watch(scoreboardEnabledProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scoreboard),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _refreshScoreboard,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: isEnabledAsync.when(
          data: (isEnabled) {
            if (!isEnabled) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.scoreboardDisabled,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.scoreboardDisabledMessage,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            // Scoreboard is enabled - fetch and display data
            final scoreboardAsync = ref.watch(scoreboardDataProvider);

            return scoreboardAsync.when(
              data: (scoreboard) {
                if (scoreboard == null || scoreboard.users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noUsersFound,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                  );
                }

                // Apply admin theme and language settings
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final themeNotifier = ref.read(themeModeProvider.notifier);
                  final localeNotifier = ref.read(localeProvider.notifier);
                  
                  // Apply theme without saving to backend
                  themeNotifier.setThemeMode(
                    scoreboard.adminPrefersDarkMode, 
                    saveToBackend: false,
                  );
                  
                  // Apply locale without saving to backend
                  localeNotifier.setLocale(
                    Locale(scoreboard.adminPreferredLanguage), 
                    saveToBackend: false,
                  );
                });

                // Responsive layout - vertical on mobile, horizontal on tablet/desktop
                return LayoutBuilder(
                  builder: (context, constraints) {
                    // Use vertical layout on mobile (width < 768px), horizontal on tablet/desktop
                    final isMobile = constraints.maxWidth < 768;

                    if (isMobile) {
                      // Mobile: Vertical layout
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // All users
                            ...scoreboard.users.map((user) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _UserScoreboardCard(user: user),
                            )),
                            
                            // All Users Tasks section
                            if (scoreboard.allUsersTasks.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              ...scoreboard.allUsersTasks.map((task) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _AllUsersTaskItem(task: task),
                              )),
                            ] else ...[
                              const SizedBox(height: 8),
                              _EmptyColumn(message: l10n.noSharedTasks),
                            ],
                          ],
                        ),
                      );
                    }

                    // Tablet/Desktop: Three-column horizontal layout
                    final midPoint = (scoreboard.users.length / 2).ceil();
                    final firstColumnUsers =
                        scoreboard.users.take(midPoint).toList();
                    final secondColumnUsers =
                        scoreboard.users.skip(midPoint).toList();

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // First column - First half of users
                        Expanded(
                          child: _UserColumn(users: firstColumnUsers),
                        ),
                        const SizedBox(width: 16),

                        // Second column - Second half of users
                        Expanded(
                          child: _UserColumn(users: secondColumnUsers),
                        ),
                        const SizedBox(width: 16),

                        // Third column - All Users Tasks
                        Expanded(
                          child: scoreboard.allUsersTasks.isNotEmpty
                              ? _AllUsersTasksColumn(
                                  tasks: scoreboard.allUsersTasks)
                              : _EmptyColumn(message: l10n.noSharedTasks),
                        ),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.errorLoadingScoreboardData,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.errorLoadingScoreboard,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UserColumn extends StatelessWidget {
  final List<UserScoreboard> users;

  const _UserColumn({required this.users});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: users.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _UserScoreboardCard(user: users[index]);
      },
    );
  }
}

class _AllUsersTasksColumn extends StatelessWidget {
  final List<ScoreboardTask> tasks;

  const _AllUsersTasksColumn({required this.tasks});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: tasks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return _AllUsersTaskItem(task: tasks[index]);
      },
    );
  }
}

class _EmptyColumn extends StatelessWidget {
  final String message;

  const _EmptyColumn({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _AllUsersTaskItem extends StatelessWidget {
  final ScoreboardTask task;

  const _AllUsersTaskItem({required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              size: 20,
              color: Colors.red,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                task.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${task.points}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFFFD700), // Yellow/gold color
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserScoreboardCard extends StatelessWidget {
  final UserScoreboard user;

  const _UserScoreboardCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User header with name and points
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  backgroundImage: user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty
                      ? NetworkImage(user.profileImageUrl!)
                      : null,
                  child: user.profileImageUrl == null || user.profileImageUrl!.isEmpty
                      ? Text(
                          user.name.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    user.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Text(
                  '${user.points}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: const Color(0xFFFFD700), // Yellow/gold color
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),

            // Tasks section
            if (user.tasks.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...user.tasks.map((task) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: _TaskItem(task: task),
                  )),
            ] else ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 20,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.noPendingTasks,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TaskItem extends StatelessWidget {
  final ScoreboardTask task;

  const _TaskItem({required this.task});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: 20,
            color: Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              task.title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${task.points}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFFFFD700), // Yellow/gold color
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
