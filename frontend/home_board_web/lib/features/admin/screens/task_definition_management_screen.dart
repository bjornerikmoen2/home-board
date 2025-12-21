import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../models/task_definition_models.dart';
import '../providers/task_definition_provider.dart';
import '../providers/user_management_provider.dart';

class TaskDefinitionManagementScreen extends ConsumerWidget {
  const TaskDefinitionManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskDefinitionsAsync = ref.watch(taskDefinitionManagementProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.taskDefinitions),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(taskDefinitionManagementProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.taskDefinitions,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showCreateTaskDialog(context, ref),
                      icon: const Icon(Icons.add),
                      label: Text(context.l10n.addTask),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: taskDefinitionsAsync.when(
                    data: (tasks) {
                      if (tasks.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.task_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                context.l10n.noTaskDefinitions,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                context.l10n.createFirstTask,
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
                          return _buildTaskCard(context, ref, task);
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
                            context.l10n.errorLoadingTasks,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.l10n.errorMessage(error.toString()),
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => ref
                                .read(taskDefinitionManagementProvider.notifier)
                                .refresh(),
                            child: Text(context.l10n.retry),
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

  Widget _buildTaskCard(BuildContext context, WidgetRef ref,
      TaskDefinitionManagementModel task) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: task.isActive ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.task_alt,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (task.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.description!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${task.defaultPoints} pts',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            if (!task.isActive)
              Chip(
                label: Text(context.l10n.inactive),
                backgroundColor: Colors.grey,
                labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _showAssignTaskDialog(context, ref, task),
              icon: const Icon(Icons.person_add, size: 18),
              label: Text(context.l10n.assign),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _showEditTaskDialog(context, ref, task);
                    break;
                  case 'delete':
                    _showDeleteConfirmationDialog(context, ref, task);
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(Icons.edit),
                      const SizedBox(width: 8),
                      Text(context.l10n.edit),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(context.l10n.delete, style: const TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateTaskDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final pointsController = TextEditingController(text: '10');
    bool isLoading = false;
    String? errorMessage;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(context.l10n.createTaskDefinition),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: '${context.l10n.title} *',
                      hintText: 'e.g., Clean Your Room',
                      prefixIcon: const Icon(Icons.title),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: context.l10n.description,
                      hintText: 'What needs to be done?',
                      prefixIcon: const Icon(Icons.description),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: pointsController,
                    decoration: InputDecoration(
                      labelText: '${context.l10n.points} *',
                      hintText: 'How many points is this worth?',
                      prefixIcon: const Icon(Icons.star),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
              child: Text(context.l10n.cancel),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (titleController.text.isEmpty) {
                        setState(() {
                          errorMessage = context.l10n.titleRequired;
                        });
                        return;
                      }

                      final points = int.tryParse(pointsController.text);
                      if (points == null || points <= 0) {
                        setState(() {
                          errorMessage = context.l10n.pointsPositiveNumber;
                        });
                        return;
                      }

                      setState(() {
                        isLoading = true;
                        errorMessage = null;
                      });

                      try {
                        await ref
                            .read(taskDefinitionManagementProvider.notifier)
                            .createTaskDefinition(
                              CreateTaskDefinitionRequestModel(
                                title: titleController.text,
                                description: descriptionController.text.isEmpty
                                    ? null
                                    : descriptionController.text,
                                defaultPoints: points,
                              ),
                            );
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(context.l10n.taskCreatedSuccessfully),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        setState(() {
                          isLoading = false;
                          errorMessage = e.toString();
                        });
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(context.l10n.create),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTaskDialog(BuildContext context, WidgetRef ref,
      TaskDefinitionManagementModel task) {
    final titleController = TextEditingController(text: task.title);
    final descriptionController =
        TextEditingController(text: task.description ?? '');
    final pointsController =
        TextEditingController(text: task.defaultPoints.toString());
    bool isActive = task.isActive;
    bool isLoading = false;
    String? errorMessage;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(context.l10n.editTaskDefinition),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: '${context.l10n.title} *',
                      prefixIcon: const Icon(Icons.title),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: context.l10n.description,
                      prefixIcon: const Icon(Icons.description),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: pointsController,
                    decoration: InputDecoration(
                      labelText: '${context.l10n.points} *',
                      prefixIcon: const Icon(Icons.star),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: Text(context.l10n.active),
                    subtitle: Text(context.l10n.taskCanBeAssigned),
                    value: isActive,
                    onChanged: (value) {
                      setState(() => isActive = value);
                    },
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
              child: Text(context.l10n.cancel),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (titleController.text.isEmpty) {
                        setState(() {
                          errorMessage = context.l10n.titleRequired;
                        });
                        return;
                      }

                      final points = int.tryParse(pointsController.text);
                      if (points == null || points <= 0) {
                        setState(() {
                          errorMessage = context.l10n.pointsPositiveNumber;
                        });
                        return;
                      }

                      setState(() {
                        isLoading = true;
                        errorMessage = null;
                      });

                      try {
                        await ref
                            .read(taskDefinitionManagementProvider.notifier)
                            .updateTaskDefinition(
                              task.id,
                              UpdateTaskDefinitionRequestModel(
                                title: titleController.text,
                                description: descriptionController.text.isEmpty
                                    ? null
                                    : descriptionController.text,
                                defaultPoints: points,
                                isActive: isActive,
                              ),
                            );
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(context.l10n.taskUpdatedSuccessfully),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        setState(() {
                          isLoading = false;
                          errorMessage = e.toString();
                        });
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(context.l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref,
      TaskDefinitionManagementModel task) {
    bool isLoading = false;
    String? errorMessage;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(context.l10n.deleteTaskDefinition),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.deleteTaskConfirmation(task.title)),
              const SizedBox(height: 8),
              Text(
                context.l10n.deleteTaskWarning,
                style: const TextStyle(color: Colors.orange),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
              child: Text(context.l10n.cancel),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      setState(() {
                        isLoading = true;
                        errorMessage = null;
                      });

                      try {
                        await ref
                            .read(taskDefinitionManagementProvider.notifier)
                            .deleteTaskDefinition(task.id);
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(context.l10n.taskDeletedSuccessfully),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        setState(() {
                          isLoading = false;
                          errorMessage = e.toString();
                        });
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(context.l10n.delete),
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignTaskDialog(BuildContext context, WidgetRef ref,
      TaskDefinitionManagementModel task) {
    // Navigate directly to the assignments screen
    context.go('/admin/assignments');
  }
}
