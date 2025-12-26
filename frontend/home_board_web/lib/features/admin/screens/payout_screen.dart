import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../providers/payout_provider.dart';

class PayoutScreen extends ConsumerStatefulWidget {
  const PayoutScreen({super.key});

  @override
  ConsumerState<PayoutScreen> createState() => _PayoutScreenState();
}

class _PayoutScreenState extends ConsumerState<PayoutScreen> {
  final Set<String> _selectedUserIds = {};
  bool _selectAll = false;

  @override
  Widget build(BuildContext context) {
    final previewAsync = ref.watch(payoutPreviewProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.payoutManagement),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(payoutPreviewProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: previewAsync.when(
              data: (preview) {
                if (preview.userPayouts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.payments_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.l10n.noUsersForPayout,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSummaryCard(context, preview),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: _selectAll,
                          onChanged: (value) {
                            setState(() {
                              _selectAll = value ?? false;
                              if (_selectAll) {
                                _selectedUserIds.addAll(
                                    preview.userPayouts.map((u) => u.userId));
                              } else {
                                _selectedUserIds.clear();
                              }
                            });
                          },
                        ),
                        Text(
                          context.l10n.selectAll,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.separated(
                        itemCount: preview.userPayouts.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final userPayout = preview.userPayouts[index];
                          return _buildUserPayoutCard(
                              context, userPayout, preview.pointToMoneyRate);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildExecuteButton(context, preview),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
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
                      context.l10n.error,
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
                      onPressed: () =>
                          ref.read(payoutPreviewProvider.notifier).refresh(),
                      child: Text(context.l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, preview) {
    final formatter =
        NumberFormat.currency(locale: 'nb_NO', symbol: 'kr', decimalDigits: 2);
    final selectedTotal = preview.userPayouts
        .where((u) => _selectedUserIds.contains(u.userId))
        .fold<double>(0.0, (sum, u) => sum + u.moneyToPay);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.totalToPay,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      formatter.format(preview.totalMoneyToPay),
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    Text(
                      'All Users',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const VerticalDivider(),
                Column(
                  children: [
                    Text(
                      formatter.format(selectedTotal),
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    Text(
                      'Selected (${_selectedUserIds.length})',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserPayoutCard(
      BuildContext context, userPayout, double rate) {
    final formatter =
        NumberFormat.currency(locale: 'nb_NO', symbol: 'kr', decimalDigits: 2);
    final isSelected = _selectedUserIds.contains(userPayout.userId);
    final dateFormatter = DateFormat.yMMMd();

    return Card(
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (value) {
          setState(() {
            if (value ?? false) {
              _selectedUserIds.add(userPayout.userId);
            } else {
              _selectedUserIds.remove(userPayout.userId);
              _selectAll = false;
            }
          });
        },
        title: Text(
          userPayout.displayName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${context.l10n.lastPayout}: ${userPayout.lastPayoutAt != null ? dateFormatter.format(userPayout.lastPayoutAt!) : context.l10n.never}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.stars, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${context.l10n.netPoints}: ${userPayout.netPointsSinceLastPayout}',
                  style: TextStyle(
                    color: userPayout.netPointsSinceLastPayout >= 0
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        secondary: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              formatter.format(userPayout.moneyToPay),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: userPayout.moneyToPay > 0
                        ? Colors.green
                        : Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              context.l10n.moneyToPay,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExecuteButton(BuildContext context, preview) {
    final formatter =
        NumberFormat.currency(locale: 'nb_NO', symbol: 'kr', decimalDigits: 2);
    final selectedTotal = preview.userPayouts
        .where((u) => _selectedUserIds.contains(u.userId))
        .fold<double>(0.0, (sum, u) => sum + u.moneyToPay);

    return ElevatedButton.icon(
      onPressed: _selectedUserIds.isEmpty
          ? null
          : () => _showExecuteConfirmation(context, selectedTotal),
      icon: const Icon(Icons.payments),
      label: Text(context.l10n.executePayout),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(20),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showExecuteConfirmation(BuildContext context, double amount) {
    final formatter =
        NumberFormat.currency(locale: 'nb_NO', symbol: 'kr', decimalDigits: 2);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.executePayout),
        content: Text(
          context.l10n.executePayoutConfirmation(
            _selectedUserIds.length,
            formatter.format(amount),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _executePayout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text(context.l10n.confirm),
          ),
        ],
      ),
    );
  }

  Future<void> _executePayout() async {
    try {
      final response = await ref
          .read(payoutPreviewProvider.notifier)
          .executePayout(userIds: _selectedUserIds.toList());

      setState(() {
        _selectedUserIds.clear();
        _selectAll = false;
      });

      if (mounted) {
        final formatter = NumberFormat.currency(
            locale: 'nb_NO', symbol: 'kr', decimalDigits: 2);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.payoutExecutedSuccessfully(
                response.usersProcessed,
                formatter.format(response.totalMoneyPaid),
              ),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.errorMessage(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
