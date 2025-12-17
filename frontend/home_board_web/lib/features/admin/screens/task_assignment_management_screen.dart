import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/task_assignment_models.dart';
import '../models/task_definition_models.dart';
import '../models/user_management_models.dart';
import '../providers/task_assignment_provider.dart';
import '../providers/task_definition_provider.dart';
import '../providers/user_management_provider.dart';

class TaskAssignmentManagementScreen extends ConsumerStatefulWidget {
  const TaskAssignmentManagementScreen({super.key});

  @override
  ConsumerState<TaskAssignmentManagementScreen> createState() =>
      _TaskAssignmentManagementScreenState();
}

class _TaskAssignmentManagementScreenState
    extends ConsumerState<TaskAssignmentManagementScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(taskAssignmentManagementProvider.notifier).refresh();
      ref.read(taskDefinitionManagementProvider.notifier).refresh();
      ref.read(userManagementProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final assignmentsAsync = ref.watch(taskAssignmentManagementProvider);
    final taskDefinitionsAsync = ref.watch(taskDefinitionManagementProvider);
    final usersAsync = ref.watch(userManagementProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Assignments'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(taskAssignmentManagementProvider.notifier).refresh(),
          ),
        ],
      ),
      body: assignmentsAsync.when(
        data: (assignments) => _buildAssignmentsList(assignments),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref
                    .read(taskAssignmentManagementProvider.notifier)
                    .refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateAssignmentDialog(
          taskDefinitionsAsync.value ?? [],
          usersAsync.value ?? [],
        ),
        icon: const Icon(Icons.add),
        label: const Text('New Assignment'),
      ),
    );
  }

  Widget _buildAssignmentsList(List<TaskAssignmentModel> assignments) {
    if (assignments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No task assignments yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Create an assignment to get started',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final assignment = assignments[index];
        return _buildAssignmentCard(assignment);
      },
    );
  }

  Widget _buildAssignmentCard(TaskAssignmentModel assignment) {
    final scheduleTypeText = _getScheduleTypeText(assignment.scheduleType);
    final daysText = _getDaysOfWeekText(assignment.daysOfWeek);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assignment.taskTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.person, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            assignment.assignedToName,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditAssignmentDialog(assignment);
                    } else if (value == 'delete') {
                      _showDeleteConfirmationDialog(assignment);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  scheduleTypeText,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            if (assignment.scheduleType == 1 && daysText.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const SizedBox(width: 24),
                  Text(daysText, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ],
            if (assignment.dueTime != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text('Due: ${assignment.dueTime}'),
                ],
              ),
            ],
            if (assignment.startDate != null || assignment.endDate != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.date_range, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    '${assignment.startDate ?? 'No start'} - ${assignment.endDate ?? 'No end'}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: assignment.isActive ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    assignment.isActive ? 'Active' : 'Inactive',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getScheduleTypeText(int scheduleType) {
    switch (scheduleType) {
      case 0:
        return 'Daily';
      case 1:
        return 'Weekly';
      case 2:
        return 'Once';
      default:
        return 'Unknown';
    }
  }

  String _getDaysOfWeekText(int daysOfWeek) {
    final days = <String>[];
    if (daysOfWeek & 1 != 0) days.add('Sun');
    if (daysOfWeek & 2 != 0) days.add('Mon');
    if (daysOfWeek & 4 != 0) days.add('Tue');
    if (daysOfWeek & 8 != 0) days.add('Wed');
    if (daysOfWeek & 16 != 0) days.add('Thu');
    if (daysOfWeek & 32 != 0) days.add('Fri');
    if (daysOfWeek & 64 != 0) days.add('Sat');
    return days.join(', ');
  }

  void _showCreateAssignmentDialog(
    List<TaskDefinitionManagementModel> taskDefinitions,
    List<UserManagementModel> users,
  ) {
    if (taskDefinitions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No task definitions available. Create one first.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (users.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No users available. Create a user first.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    String? selectedTaskId;
    String? selectedUserId;
    int scheduleType = 0; // Daily
    Set<int> selectedDays = {1, 2, 4, 8, 16, 32, 64}; // All days
    DateTime? startDate;
    DateTime? endDate;
    TimeOfDay? dueTime;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create Task Assignment'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Task',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedTaskId,
                    items: taskDefinitions
                        .where((t) => t.isActive)
                        .map((task) => DropdownMenuItem(
                              value: task.id,
                              child: Text(task.title),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setDialogState(() => selectedTaskId = value),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Assign To',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedUserId,
                    items: users
                        .map((user) => DropdownMenuItem(
                              value: user.id,
                              child: Text(user.displayName),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setDialogState(() => selectedUserId = value),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Schedule Type',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 0, label: Text('Daily')),
                      ButtonSegment(value: 1, label: Text('Weekly')),
                      ButtonSegment(value: 2, label: Text('Once')),
                    ],
                    selected: {scheduleType},
                    onSelectionChanged: (Set<int> newSelection) {
                      setDialogState(() => scheduleType = newSelection.first);
                    },
                  ),
                  if (scheduleType == 1) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Days of Week',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildDayPicker(
                      selectedDays: selectedDays,
                      onChanged: (days) =>
                          setDialogState(() => selectedDays = days),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: startDate ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setDialogState(() => startDate = date);
                            }
                          },
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            startDate == null
                                ? 'Start Date (Optional)'
                                : DateFormat('yyyy-MM-dd').format(startDate!),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (startDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () =>
                              setDialogState(() => startDate = null),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: endDate ?? startDate ?? DateTime.now(),
                              firstDate: startDate ?? DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setDialogState(() => endDate = date);
                            }
                          },
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            endDate == null
                                ? 'End Date (Optional)'
                                : DateFormat('yyyy-MM-dd').format(endDate!),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (endDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setDialogState(() => endDate = null),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: dueTime ?? TimeOfDay.now(),
                            );
                            if (time != null) {
                              setDialogState(() => dueTime = time);
                            }
                          },
                          icon: const Icon(Icons.access_time),
                          label: Text(
                            dueTime == null
                                ? 'Due Time (Optional)'
                                : dueTime!.format(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (dueTime != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setDialogState(() => dueTime = null),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedTaskId == null || selectedUserId == null
                  ? null
                  : () async {
                      try {
                        final daysOfWeek = scheduleType == 1
                            ? selectedDays.fold(0, (sum, day) => sum | day)
                            : 127; // All days for daily/once

                        final request = CreateTaskAssignmentRequest(
                          taskDefinitionId: selectedTaskId!,
                          assignedToUserId: selectedUserId!,
                          scheduleType: scheduleType,
                          daysOfWeek: daysOfWeek,
                          startDate: startDate != null
                              ? DateFormat('yyyy-MM-dd').format(startDate!)
                              : null,
                          endDate: endDate != null
                              ? DateFormat('yyyy-MM-dd').format(endDate!)
                              : null,
                          dueTime: dueTime != null
                              ? '${dueTime!.hour.toString().padLeft(2, '0')}:${dueTime!.minute.toString().padLeft(2, '0')}'
                              : null,
                        );

                        await ref
                            .read(taskAssignmentManagementProvider.notifier)
                            .createTaskAssignment(request);

                        if (context.mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Assignment created successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayPicker({
    required Set<int> selectedDays,
    required Function(Set<int>) onChanged,
  }) {
    final days = [
      {'name': 'Sun', 'value': 1},
      {'name': 'Mon', 'value': 2},
      {'name': 'Tue', 'value': 4},
      {'name': 'Wed', 'value': 8},
      {'name': 'Thu', 'value': 16},
      {'name': 'Fri', 'value': 32},
      {'name': 'Sat', 'value': 64},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: days.map((day) {
        final isSelected = selectedDays.contains(day['value']);
        return FilterChip(
          label: Text(day['name'] as String),
          selected: isSelected,
          onSelected: (selected) {
            final newSelectedDays = Set<int>.from(selectedDays);
            if (selected) {
              newSelectedDays.add(day['value'] as int);
            } else {
              newSelectedDays.remove(day['value'] as int);
            }
            onChanged(newSelectedDays);
          },
        );
      }).toList(),
    );
  }

  void _showEditAssignmentDialog(TaskAssignmentModel assignment) {
    bool isActive = assignment.isActive;
    TimeOfDay? dueTime = assignment.dueTime != null
        ? TimeOfDay(
            hour: int.parse(assignment.dueTime!.split(':')[0]),
            minute: int.parse(assignment.dueTime!.split(':')[1]),
          )
        : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Assignment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                assignment.taskTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Assigned to: ${assignment.assignedToName}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Active'),
                value: isActive,
                onChanged: (value) => setDialogState(() => isActive = value),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: dueTime ?? TimeOfDay.now(),
                        );
                        if (time != null) {
                          setDialogState(() => dueTime = time);
                        }
                      },
                      icon: const Icon(Icons.access_time),
                      label: Text(
                        dueTime == null
                            ? 'Due Time (Optional)'
                            : dueTime!.format(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (dueTime != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setDialogState(() => dueTime = null),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final request = UpdateTaskAssignmentRequest(
                    isActive: isActive,
                    dueTime: dueTime != null
                        ? '${dueTime!.hour.toString().padLeft(2, '0')}:${dueTime!.minute.toString().padLeft(2, '0')}'
                        : null,
                  );

                  await ref
                      .read(taskAssignmentManagementProvider.notifier)
                      .updateTaskAssignment(assignment.id, request);

                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Assignment updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(TaskAssignmentModel assignment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Assignment'),
        content: Text(
          'Are you sure you want to delete the assignment "${assignment.taskTitle}" for ${assignment.assignedToName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref
                    .read(taskAssignmentManagementProvider.notifier)
                    .deleteTaskAssignment(assignment.id);

                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Assignment deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
