import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/l10n_extensions.dart';

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.adminPanel),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.l10n.adminDashboard,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Use responsive grid layout
                      final crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
                      final childAspectRatio = constraints.maxWidth > 600 ? 2.0 : 2.5;
                      
                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: childAspectRatio,
                        children: [
                          _buildAdminCard(
                            context,
                            title: context.l10n.users,
                            icon: Icons.people,
                            onTap: () => context.go('/admin/users'),
                          ),
                          _buildAdminCard(
                            context,
                            title: context.l10n.taskDefinitions,
                            icon: Icons.task,
                            onTap: () => context.go('/admin/tasks'),
                          ),
                          _buildAdminCard(
                            context,
                            title: context.l10n.taskAssignments,
                            icon: Icons.assignment,
                            onTap: () => context.go('/admin/assignments'),
                          ),
                          _buildAdminCard(
                            context,
                            title: context.l10n.verificationQueue,
                            icon: Icons.verified,
                            onTap: () => context.go('/admin/verification-queue'),
                          ),
                          _buildAdminCard(
                            context,
                            title: context.l10n.payout,
                            icon: Icons.payments,
                            onTap: () => context.go('/admin/payout'),
                          ),
                          _buildAdminCard(
                            context,
                            title: context.l10n.analytics,
                            icon: Icons.analytics,
                            onTap: () => context.go('/analytics'),
                          ),
                          _buildAdminCard(
                            context,
                            title: context.l10n.settings,
                            icon: Icons.settings,
                            onTap: () => context.go('/admin/settings'),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
