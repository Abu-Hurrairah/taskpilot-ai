import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../widgets/components.dart';

class ProScreen extends StatelessWidget {
  final AppState state;
  const ProScreen(this.state, {super.key});
  @override
  Widget build(BuildContext context) {
    final rc = state.revenue;
    return PageBody(children: [
      const SectionTitle('More clarity.\nMore momentum.',
          'TaskPilot Pro gives bigger goals the space they need.'),
      Align(alignment: Alignment.centerLeft, child: Chip(label: Text(rc.mode))),
      const SizedBox(height: 12),
      Card(
          color: pilotPurple,
          child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.workspace_premium_outlined,
                        color: Colors.white, size: 40),
                    const SizedBox(height: 16),
                    Text(
                        rc.entitled
                            ? 'Pro is active'
                            : rc.preview
                                ? 'Pro demo preview'
                                : 'Unlock TaskPilot Pro',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    const Text(
                        'Unlimited generations. A deeper breakdown. A focused daily plan.',
                        style: TextStyle(color: Colors.white, fontSize: 16))
                  ]))),
      const SizedBox(height: 12),
      const ListTile(
          leading: Icon(Icons.all_inclusive),
          title: Text('Unlimited plan generation'),
          subtitle:
              Text('Free includes 3 successful generations per installation.')),
      const ListTile(
          leading: Icon(Icons.account_tree_outlined),
          title: Text('Advanced task breakdown'),
          subtitle: Text('Three actionable subtasks per local-planner task.')),
      const ListTile(
          leading: Icon(Icons.bolt_outlined),
          title: Text('Priority-focused daily plan'),
          subtitle:
              Text('Today sorts urgent work first, within your time budget.')),
      const ListTile(
          leading: Icon(Icons.insights_outlined),
          title: Text('Productivity insights'),
          subtitle: Text(
              'See completed tasks, completion rate and remaining effort.')),
      Card(
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rc.mode,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(rc.demoMode
                        ? 'No billing SDK key is configured for this device. Preview only: no payment, transaction or RevenueCat entitlement is created.'
                        : 'Packages and prices below come from RevenueCat. Pro unlocks only when taskpilot_pro is active.'),
                    if (rc.error != null) ...[
                      const SizedBox(height: 8),
                      Text(rc.error!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error))
                    ]
                  ]))),
      const SizedBox(height: 12),
      if (rc.demoMode)
        FilledButton.icon(
            onPressed: () => rc.setPreview(!rc.preview),
            icon: const Icon(Icons.science_outlined),
            label: Text(rc.preview
                ? 'Leave Pro demo preview'
                : 'Preview Pro • no purchase')),
      if (!rc.demoMode) ...[
        ...rc.packages.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FilledButton(
                onPressed: rc.busy
                    ? null
                    : () async {
                        final result = await rc.purchase(p);
                        if (context.mounted) {
                          message(context, result);
                        }
                      },
                child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                        '${p.storeProduct.title} • ${p.storeProduct.priceString}'))))),
        if (rc.packages.isEmpty)
          OutlinedButton(
              onPressed: rc.busy ? null : rc.refresh,
              child: const Text('Reload RevenueCat offerings'))
      ],
      TextButton(
          onPressed: rc.busy
              ? null
              : () async {
                  final result = await rc.restore();
                  if (context.mounted) {
                    message(context, result);
                  }
                },
          child: const Text('Restore purchases')),
      if (rc.busy) const Center(child: CircularProgressIndicator()),
      const SizedBox(height: 12),
      const Text(
          'Test Store purchases use simulated billing and do not charge money. Store subscriptions use the displayed billing period and renew according to the store terms. Manage or cancel store subscriptions through your store account.',
          style: TextStyle(fontSize: 12))
    ]);
  }
}
