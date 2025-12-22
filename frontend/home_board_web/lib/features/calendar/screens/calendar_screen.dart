import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../models/calendar_models.dart';
import '../providers/calendar_provider.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadMonthTasks();
  }

  void _loadMonthTasks() {
    final startDate = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final endDate = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    ref.read(calendarProvider.notifier).updateDateRange(startDate, endDate);
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
      _loadMonthTasks();
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
      _loadMonthTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(calendarProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(calendarProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildMonthSelector(),
          Expanded(
            child: tasksAsync.when(
              data: (tasks) => _buildCalendarView(tasks),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(context.l10n.error),
                    const SizedBox(height: 8),
                    Text(error.toString()),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          ref.read(calendarProvider.notifier).refresh(),
                      child: Text(context.l10n.refresh),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _previousMonth,
          ),
          Text(
            DateFormat.yMMMM().format(_selectedMonth),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _nextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarView(List<CalendarTaskModel> tasks) {
    // Group tasks by date
    final tasksByDate = <DateTime, List<CalendarTaskModel>>{};
    for (var task in tasks) {
      final date = DateTime.parse(task.date);
      final dateKey = DateTime(date.year, date.month, date.day);
      tasksByDate.putIfAbsent(dateKey, () => []).add(task);
    }

    // Get first and last day of month
    final firstDayOfMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDayOfMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);

    // Get first day of calendar (might be from previous month)
    final firstDayOfCalendar = firstDayOfMonth
        .subtract(Duration(days: firstDayOfMonth.weekday % 7));

    // Build calendar grid
    final days = <DateTime>[];
    var currentDay = firstDayOfCalendar;
    while (currentDay.isBefore(lastDayOfMonth) ||
        currentDay.month == lastDayOfMonth.month) {
      days.add(currentDay);
      currentDay = currentDay.add(const Duration(days: 1));
    }

    // Add remaining days to complete the week
    while (days.length % 7 != 0) {
      days.add(currentDay);
      currentDay = currentDay.add(const Duration(days: 1));
    }

    return Column(
      children: [
        // Weekday headers
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                .map((day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        // Calendar grid
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.8,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              final isCurrentMonth = day.month == _selectedMonth.month;
              final isToday = DateTime.now().year == day.year &&
                  DateTime.now().month == day.month &&
                  DateTime.now().day == day.day;
              final dayTasks = tasksByDate[day] ?? [];

              return _buildDayCell(
                day,
                dayTasks,
                isCurrentMonth: isCurrentMonth,
                isToday: isToday,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDayCell(
    DateTime day,
    List<CalendarTaskModel> tasks, {
    required bool isCurrentMonth,
    required bool isToday,
  }) {
    final completedCount = tasks.where((t) => t.isCompleted).length;
    final totalCount = tasks.length;

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        border: Border.all(
          color: isToday
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade300,
          width: isToday ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: isCurrentMonth ? null : Colors.grey.shade100,
      ),
      child: InkWell(
        onTap: tasks.isEmpty
            ? null
            : () => _showDayTasks(context, day, tasks),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                day.day.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: isCurrentMonth
                      ? (isToday
                          ? Theme.of(context).colorScheme.primary
                          : null)
                      : Colors.grey,
                ),
              ),
              if (tasks.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  '$completedCount/$totalCount',
                  style: TextStyle(
                    fontSize: 11,
                    color: completedCount == totalCount
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
                const SizedBox(height: 2),
                ...tasks.take(2).map((task) => Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: task.isCompleted
                            ? Colors.green.shade100
                            : Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        task.title,
                        style: const TextStyle(fontSize: 9),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )),
                if (tasks.length > 2)
                  Text(
                    '+${tasks.length - 2} more',
                    style: const TextStyle(fontSize: 9, color: Colors.grey),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showDayTasks(
      BuildContext context, DateTime day, List<CalendarTaskModel> tasks) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat.yMMMd().format(day),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          task.isCompleted
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color:
                              task.isCompleted ? Colors.green : Colors.grey,
                        ),
                        title: Text(task.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (task.description != null)
                              Text(task.description!),
                            Text('${task.assignedToName} • ${task.defaultPoints} pts'),
                            if (task.dueTime != null)
                              Text('Due: ${task.dueTime}'),
                          ],
                        ),
                        trailing: task.isCompleted
                            ? const Icon(Icons.verified, color: Colors.green)
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
