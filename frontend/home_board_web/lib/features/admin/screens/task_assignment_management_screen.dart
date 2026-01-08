import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../models/family_settings_models.dart';
import '../models/task_assignment_models.dart';
import '../models/task_definition_models.dart';
import '../models/user_management_models.dart';
import '../providers/family_settings_provider.dart';
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
      ref.read(familySettingsNotifierProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final assignmentsAsync = ref.watch(taskAssignmentManagementProvider);
    final taskDefinitionsAsync = ref.watch(taskDefinitionManagementProvider);
    final usersAsync = ref.watch(userManagementProvider);
    final settingsAsync = ref.watch(familySettingsNotifierProvider);
    final weekStartsOn = settingsAsync.value?.weekStartsOn ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.taskAssignments),
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
        data: (assignments) => _buildAssignmentsList(assignments, weekStartsOn),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(context.l10n.errorMessage(error.toString())),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref
                    .read(taskAssignmentManagementProvider.notifier)
                    .refresh(),
                child: Text(context.l10n.retry),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateAssignmentDialog(
          taskDefinitionsAsync.value ?? [],
          usersAsync.value ?? [],
          weekStartsOn,
        ),
        icon: const Icon(Icons.add),
        label: Text(context.l10n.newAssignment),
      ),
    );
  }

  Widget _buildAssignmentsList(List<TaskAssignmentModel> assignments, int weekStartsOn) {
    if (assignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              context.l10n.noAssignmentsYet,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.createAssignmentToStart,
              style: const TextStyle(color: Colors.grey),
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
        return _buildAssignmentCard(assignment, weekStartsOn);
      },
    );
  }

  Widget _buildAssignmentCard(TaskAssignmentModel assignment, int weekStartsOn) {
    final scheduleTypeText = _getScheduleTypeText(assignment.scheduleType);
    final daysText = _getDaysOfWeekText(assignment.daysOfWeek);
    
    // Determine assigned to text
    String assignedToText;
    if (assignment.assignedToGroup != null) {
      assignedToText = assignment.assignedToGroup == 1
          ? context.l10n.allUsers 
          : (assignment.assignedToGroup == 0 
              ? context.l10n.adminGroup 
              : context.l10n.userGroup);
    } else {
      assignedToText = assignment.assignedToName ?? 'Unknown';
    }

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
                          Icon(
                            assignment.assignedToGroup != null 
                                ? Icons.group 
                                : Icons.person, 
                            size: 16, 
                            color: Colors.grey
                          ),
                          const SizedBox(width: 4),
                          Text(
                            assignedToText,
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
                      _showEditAssignmentDialog(assignment, weekStartsOn);
                    } else if (value == 'delete') {
                      _showDeleteConfirmationDialog(assignment);
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
                    assignment.isActive ? context.l10n.active : context.l10n.inactive,
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
        return context.l10n.daily;
      case 1:
        return context.l10n.weekly;
      case 2:
        return context.l10n.once;
      case 3:
        return context.l10n.duringWeek;
      case 4:
        return context.l10n.duringMonth;
      default:
        return context.l10n.unknown;
    }
  }

  String _getDaysOfWeekText(int daysOfWeek) {
    final days = <String>[];
    if (daysOfWeek & 1 != 0) days.add(context.l10n.sun);
    if (daysOfWeek & 2 != 0) days.add(context.l10n.mon);
    if (daysOfWeek & 4 != 0) days.add(context.l10n.tue);
    if (daysOfWeek & 8 != 0) days.add(context.l10n.wed);
    if (daysOfWeek & 16 != 0) days.add(context.l10n.thu);
    if (daysOfWeek & 32 != 0) days.add(context.l10n.fri);
    if (daysOfWeek & 64 != 0) days.add(context.l10n.sat);
    return days.join(', ');
  }

  void _showCreateAssignmentDialog(
    List<TaskDefinitionManagementModel> taskDefinitions,
    List<UserManagementModel> users,
    int weekStartsOn,
  ) {
    if (taskDefinitions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.noTaskDefinitionsAvailable),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (users.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.noUsersAvailable),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    String? selectedTaskId;
    String? selectedAssignee; // Can be userId or 'ALL_USERS'
    int scheduleType = 0; // Daily
    Set<int> selectedDays = {1, 2, 4, 8, 16, 32, 64}; // All days
    DateTime? startDate;
    DateTime? endDate;
    TimeOfDay? dueTime;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(context.l10n.createTaskAssignment),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: context.l10n.task,
                      border: const OutlineInputBorder(),
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
                    decoration: InputDecoration(
                      labelText: context.l10n.assignTo,
                      border: const OutlineInputBorder(),
                    ),
                    value: selectedAssignee,
                    items: [
                      DropdownMenuItem(
                        value: 'ALL_USERS',
                        child: Row(
                          children: [
                            const Icon(Icons.people, size: 18),
                            const SizedBox(width: 8),
                            Text(context.l10n.allUsers),
                          ],
                        ),
                      ),
                      ...users.map((user) => DropdownMenuItem(
                        value: user.id,
                        child: Text(user.displayName),
                      )),
                    ],
                    onChanged: (value) =>
                        setDialogState(() => selectedAssignee = value),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: context.l10n.scheduleType,
                      border: const OutlineInputBorder(),
                    ),
                    value: scheduleType,
                    items: [
                      DropdownMenuItem(value: 0, child: Text(context.l10n.daily)),
                      DropdownMenuItem(value: 1, child: Text(context.l10n.weekly)),
                      DropdownMenuItem(value: 2, child: Text(context.l10n.once)),
                      DropdownMenuItem(value: 3, child: Text(context.l10n.duringWeek)),
                      DropdownMenuItem(value: 4, child: Text(context.l10n.duringMonth)),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => scheduleType = value);
                      }
                    },
                  ),
                  if (scheduleType == 1) ...[
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.daysOfWeek,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildDayPicker(
                      selectedDays: selectedDays,
                      onChanged: (days) =>
                          setDialogState(() => selectedDays = days),
                      weekStartsOn: weekStartsOn,
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
                                ? context.l10n.startDateOptional
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
                                ? context.l10n.endDateOptional
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
                                ? context.l10n.dueTimeOptional
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
              child: Text(context.l10n.cancel),
            ),
            ElevatedButton(
              onPressed: selectedTaskId == null || selectedAssignee == null
                  ? null
                  : () async {
                      try {
                        final daysOfWeek = scheduleType == 1
                            ? selectedDays.fold(0, (sum, day) => sum | day)
                            : 127; // All days for daily/once

                        final bool isAllUsers = selectedAssignee == 'ALL_USERS';
                        
                        final request = CreateTaskAssignmentRequest(
                          taskDefinitionId: selectedTaskId!,
                          assignedToUserId: isAllUsers ? null : selectedAssignee,
                          assignedToGroup: isAllUsers ? 1 : null,
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
                            SnackBar(
                              content: Text(context.l10n.assignmentCreatedSuccessfully),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(context.l10n.errorMessage(e.toString())),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              child: Text(context.l10n.create),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayPicker({
    required Set<int> selectedDays,
    required Function(Set<int>) onChanged,
    required int weekStartsOn,
  }) {
    final allDays = [
      {'name': context.l10n.sun, 'value': 1},
      {'name': context.l10n.mon, 'value': 2},
      {'name': context.l10n.tue, 'value': 4},
      {'name': context.l10n.wed, 'value': 8},
      {'name': context.l10n.thu, 'value': 16},
      {'name': context.l10n.fri, 'value': 32},
      {'name': context.l10n.sat, 'value': 64},
    ];
    
    // Reorder days based on weekStartsOn setting
    final days = [...allDays.sublist(weekStartsOn), ...allDays.sublist(0, weekStartsOn)];

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

  void _showEditAssignmentDialog(TaskAssignmentModel assignment, int weekStartsOn) {
    final taskDefinitionsAsync = ref.read(taskDefinitionManagementProvider);
    final usersAsync = ref.read(userManagementProvider);

    final taskDefinitions = taskDefinitionsAsync.value ?? [];
    final users = usersAsync.value ?? [];

    if (taskDefinitions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.noTaskDefinitionsAvailable),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (users.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.noUsersAvailable),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    String selectedTaskId = assignment.taskDefinitionId;
    String? selectedAssignee = assignment.assignedToGroup == 1 
        ? 'ALL_USERS' 
        : assignment.assignedToUserId;
    int scheduleType = assignment.scheduleType;
    Set<int> selectedDays = _getDaysFromBitmask(assignment.daysOfWeek);
    DateTime? startDate = assignment.startDate != null
        ? DateTime.parse(assignment.startDate!)
        : null;
    DateTime? endDate = assignment.endDate != null
        ? DateTime.parse(assignment.endDate!)
        : null;
    TimeOfDay? dueTime = assignment.dueTime != null
        ? TimeOfDay(
            hour: int.parse(assignment.dueTime!.split(':')[0]),
            minute: int.parse(assignment.dueTime!.split(':')[1]),
          )
        : null;
    bool isActive = assignment.isActive;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(context.l10n.editAssignment),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: context.l10n.task,
                      border: const OutlineInputBorder(),
                    ),
                    value: selectedTaskId,
                    items: taskDefinitions
                        .where((t) => t.isActive)
                        .map((task) => DropdownMenuItem(
                              value: task.id,
                              child: Text(task.title),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedTaskId = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: context.l10n.assignTo,
                      border: const OutlineInputBorder(),
                    ),
                    value: selectedAssignee,
                    items: [
                      DropdownMenuItem(
                        value: 'ALL_USERS',
                        child: Row(
                          children: [
                            const Icon(Icons.people, size: 18),
                            const SizedBox(width: 8),
                            Text(context.l10n.allUsers),
                          ],
                        ),
                      ),
                      ...users.map((user) => DropdownMenuItem(
                        value: user.id,
                        child: Text(user.displayName),
                      )),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedAssignee = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: context.l10n.scheduleType,
                      border: const OutlineInputBorder(),
                    ),
                    value: scheduleType,
                    items: [
                      DropdownMenuItem(value: 0, child: Text(context.l10n.daily)),
                      DropdownMenuItem(value: 1, child: Text(context.l10n.weekly)),
                      DropdownMenuItem(value: 2, child: Text(context.l10n.once)),
                      DropdownMenuItem(value: 3, child: Text(context.l10n.duringWeek)),
                      DropdownMenuItem(value: 4, child: Text(context.l10n.duringMonth)),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => scheduleType = value);
                      }
                    },
                  ),
                  if (scheduleType == 1) ...[
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.daysOfWeek,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildDayPicker(
                      selectedDays: selectedDays,
                      onChanged: (days) =>
                          setDialogState(() => selectedDays = days),
                      weekStartsOn: weekStartsOn,
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
                                ? context.l10n.startDateOptional
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
                                ? context.l10n.endDateOptional
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
                                ? context.l10n.dueTimeOptional
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
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: Text(context.l10n.active),
                    value: isActive,
                    onChanged: (value) => setDialogState(() => isActive = value),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final daysOfWeek = scheduleType == 1
                      ? selectedDays.fold(0, (sum, day) => sum | day)
                      : 127; // All days for daily/once

                  final bool isAllUsers = selectedAssignee == 'ALL_USERS';

                  // Create request with explicit JSON to ensure all fields are sent
                  final requestJson = {
                    'taskDefinitionId': selectedTaskId,
                    'assignedToUserId': isAllUsers ? null : selectedAssignee,
                    'assignedToGroup': isAllUsers ? 1 : null,
                    'scheduleType': scheduleType,
                    'daysOfWeek': daysOfWeek,
                    'startDate': startDate != null
                        ? DateFormat('yyyy-MM-dd').format(startDate!)
                        : null,
                    'endDate': endDate != null
                        ? DateFormat('yyyy-MM-dd').format(endDate!)
                        : null,
                    'dueTime': dueTime != null
                        ? '${dueTime!.hour.toString().padLeft(2, '0')}:${dueTime!.minute.toString().padLeft(2, '0')}'
                        : null,
                    'isActive': isActive,
                  };

                  final request = UpdateTaskAssignmentRequest.fromJson(requestJson);

                  await ref
                      .read(taskAssignmentManagementProvider.notifier)
                      .updateTaskAssignment(assignment.id, request);

                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.l10n.assignmentUpdatedSuccessfully),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.l10n.errorMessage(e.toString())),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(context.l10n.update),
            ),
          ],
        ),
      ),
    );
  }

  Set<int> _getDaysFromBitmask(int bitmask) {
    final days = <int>{};
    if (bitmask & 1 != 0) days.add(1);
    if (bitmask & 2 != 0) days.add(2);
    if (bitmask & 4 != 0) days.add(4);
    if (bitmask & 8 != 0) days.add(8);
    if (bitmask & 16 != 0) days.add(16);
    if (bitmask & 32 != 0) days.add(32);
    if (bitmask & 64 != 0) days.add(64);
    return days;
  }

  void _showDeleteConfirmationDialog(TaskAssignmentModel assignment) {
    // Determine assigned to text for display
    String assignedToText;
    if (assignment.assignedToGroup != null) {
      assignedToText = assignment.assignedToGroup == 1
          ? context.l10n.allUsers 
          : (assignment.assignedToGroup == 0 
              ? context.l10n.adminGroup 
              : context.l10n.userGroup);
    } else {
      assignedToText = assignment.assignedToName ?? 'Unknown';
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.deleteAssignment),
        content: Text(
          context.l10n.deleteAssignmentQuestion(assignment.taskTitle, assignedToText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.cancel),
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
                    SnackBar(
                      content: Text(context.l10n.assignmentDeletedSuccessfully),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.l10n.errorMessage(e.toString())),
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
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
  }
}
