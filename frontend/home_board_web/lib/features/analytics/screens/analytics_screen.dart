import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../providers/analytics_provider.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  int _selectedDays = 30;

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(analyticsNotifierProvider(days: _selectedDays));

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.analytics),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref
                .read(analyticsNotifierProvider(days: _selectedDays).notifier)
                .refresh(days: _selectedDays),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTimePeriodSelector(),
          Expanded(
            child: analyticsAsync.when(
              data: (analytics) => _buildAnalyticsContent(context, analytics),
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
                      onPressed: () => ref
                          .read(analyticsNotifierProvider(days: _selectedDays)
                              .notifier)
                          .refresh(days: _selectedDays),
                      child: Text(context.l10n.retry),
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

  Widget _buildTimePeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            context.l10n.timePeriod,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(width: 16),
          SegmentedButton<int>(
            segments: [
              ButtonSegment(
                value: 7,
                label: Text(context.l10n.days(7)),
              ),
              ButtonSegment(
                value: 30,
                label: Text(context.l10n.days(30)),
              ),
              ButtonSegment(
                value: 90,
                label: Text(context.l10n.days(90)),
              ),
            ],
            selected: {_selectedDays},
            onSelectionChanged: (Set<int> newSelection) {
              setState(() {
                _selectedDays = newSelection.first;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsContent(BuildContext context, analytics) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildPointsSummaryCard(context, analytics.pointsAnalytics),
        const SizedBox(height: 16),
        _buildCompletionRatesCard(context, analytics.completionRates),
        const SizedBox(height: 16),
        _buildPointsChartCard(context, analytics.pointsAnalytics),
      ],
    );
  }

  Widget _buildPointsSummaryCard(BuildContext context, pointsAnalytics) {
    final formatter = NumberFormat.currency(locale: 'nb_NO', symbol: 'kr', decimalDigits: 2);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.pointsSummary,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                  context,
                  context.l10n.totalEarned,
                  pointsAnalytics.totalEarned.toString(),
                  Colors.green,
                  Icons.arrow_upward,
                ),
                _buildStatColumn(
                  context,
                  context.l10n.totalPaidOut,
                  formatter.format(pointsAnalytics.totalPaidOut),
                  Colors.orange,
                  Icons.payments,
                ),
                _buildStatColumn(
                  context,
                  context.l10n.currentBalance,
                  pointsAnalytics.currentBalance.toString(),
                  Colors.blue,
                  Icons.account_balance_wallet,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCompletionRatesCard(BuildContext context, completionRates) {
    final avgCompletionRate = completionRates.isEmpty
        ? 0.0
        : completionRates
                .map((r) => r.completionRate)
                .reduce((a, b) => a + b) /
            completionRates.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.completionRates,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  '${context.l10n.average}: ${avgCompletionRate.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: completionRates.length,
                itemBuilder: (context, index) {
                  final dataPoint = completionRates[index];
                  final barHeight = dataPoint.completionRate * 1.5;
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (dataPoint.totalTasks > 0)
                          Text(
                            '${dataPoint.completionRate.toStringAsFixed(0)}%',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        const SizedBox(height: 4),
                        Container(
                          width: 30,
                          height: barHeight.clamp(0, 150),
                          decoration: BoxDecoration(
                            color: _getCompletionColor(dataPoint.completionRate),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat.MMMd().format(dataPoint.date),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCompletionColor(double rate) {
    if (rate >= 80) return Colors.green;
    if (rate >= 50) return Colors.orange;
    return Colors.red;
  }

  Widget _buildPointsChartCard(BuildContext context, pointsAnalytics) {
    // Combine earned (as double) and paid out (money) data by date
    final Map<DateTime, Map<String, double>> combinedData = {};
    
    for (final point in pointsAnalytics.pointsEarned) {
      combinedData[point.date] = {'earned': point.amount.toDouble(), 'paidOut': 0.0};
    }
    
    for (final point in pointsAnalytics.moneyPaidOut) {
      if (combinedData.containsKey(point.date)) {
        combinedData[point.date]!['paidOut'] = point.amount;
      } else {
        combinedData[point.date] = {'earned': 0.0, 'paidOut': point.amount};
      }
    }

    final sortedDates = combinedData.keys.toList()..sort();
    final maxValue = combinedData.values
        .map((d) => (d['earned']! > d['paidOut']!) ? d['earned']! : d['paidOut']!)
        .fold(0.0, (prev, curr) => curr > prev ? curr : prev);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.pointsEarnedVsMoneyPaidOut,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(context, context.l10n.earned, Colors.green),
                const SizedBox(width: 16),
                _buildLegendItem(context, context.l10n.paidOut, Colors.orange),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: sortedDates.isEmpty
                  ? Center(child: Text(context.l10n.noData))
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: sortedDates.length,
                      itemBuilder: (context, index) {
                        final date = sortedDates[index];
                        final data = combinedData[date]!;
                        final earnedHeight = maxValue > 0
                            ? (data['earned']! / maxValue * 150).clamp(0.0, 150.0)
                            : 0.0;
                        final paidOutHeight = maxValue > 0
                            ? (data['paidOut']! / maxValue * 150).clamp(0.0, 150.0)
                            : 0.0;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    width: 20,
                                    height: earnedHeight,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    width: 20,
                                    height: paidOutHeight,
                                    decoration: const BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(4),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat.MMMd().format(date),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
