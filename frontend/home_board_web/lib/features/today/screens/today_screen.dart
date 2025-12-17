import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../tasks/providers/task_provider.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayTasksAsync = ref.watch(todayTasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Tasks'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(todayTasksProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'My Tasks for Today',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: todayTasksAsync.when(
                    data: (tasks) {
                      if (tasks.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.task_alt,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No tasks for today!',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Enjoy your free time! 🎉',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: tasks.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          final isCompleted = task.status == 'Completed' ||
                              task.status == 'Verified';
                          return _buildTaskCard(
                            context,
                            ref,
                            assignmentId: task.assignmentId,
                            title: task.taskName,
                            description: task.description,
                            points: task.pointValue,
                            isCompleted: isCompleted,
                            requiresVerification: task.requiresVerification,
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
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading tasks',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            error.toString(),
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => ref
                                .read(todayTasksProvider.notifier)
                                .refresh(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    WidgetRef ref, {
    required int assignmentId,
    required String title,
    required String description,
    required int points,
    required bool isCompleted,
    required bool requiresVerification,
  }) {
    return Card(
      color: isCompleted ? Colors.green.shade50 : null,
      child: InkWell(
        onTap: isCompleted
            ? null
            : () async {
                // Show confirmation dialog
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Complete Task'),
                    content: Text('Mark "$title" as complete?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Complete'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true && context.mounted) {
                  try {
                    await ref
                        .read(todayTasksProvider.notifier)
                        .completeTask(assignmentId);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            requiresVerification
                                ? 'Task completed! Waiting for verification.'
                                : 'Task completed! +$points points',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(
                isCompleted ? Icons.check_circle : Icons.circle_outlined,
                size: 48,
                color: isCompleted ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '$points points',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (requiresVerification) ...[
                          const SizedBox(width: 12),
                          const Icon(Icons.verified_user,
                              size: 16, color: Colors.blue),
                          const SizedBox(width: 4),
                          Text(
                            'Needs verification',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (isCompleted)
                const Chip(
                  label: Text('Completed'),
                  backgroundColor: Colors.green,
                  labelStyle: TextStyle(color: Colors.white),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
