import 'package:flutter/material.dart';
import '../core/config.dart';
import '../state/app_state.dart';
import '../widgets/components.dart';

class SettingsScreen extends StatelessWidget {
  final AppState state;
  const SettingsScreen(this.state, {super.key});
  @override
  Widget build(BuildContext context) => PageBody(children: [
        const SectionTitle(
            'Make it yours.', 'Simple settings. Transparent planning.'),
        SwitchListTile(
            title: const Text('Dark mode'),
            secondary: const Icon(Icons.dark_mode_outlined),
            value: state.dark,
            onChanged: state.setDark),
        const Divider(),
        ListTile(
            leading: const Icon(Icons.dns_outlined),
            title: const Text('Backend'),
            subtitle: Text(
                '${AppConfig.apiBaseUrl}\n${state.offline ? 'Offline • saved plans are read-only' : 'Connected'}')),
        ListTile(
            leading: const Icon(Icons.workspace_premium_outlined),
            title: const Text('Billing status'),
            subtitle:
                Text('${state.revenue.mode}\nEntitlement: taskpilot_pro')),
        ListTile(
            leading: const Icon(Icons.auto_awesome),
            title: const Text('AI transparency'),
            subtitle: const Text(
                'Default: deterministic Python planner using rules and templates. Optional: Ollama on your local backend. Invalid or unavailable LLM output falls back automatically.')),
        ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy'),
            subtitle: const Text(
                'No sign-in, analytics SDK or paid AI service. Plans are stored in your backend SQLite database and cached on this device. RevenueCat handles billing identity when configured. Ollama receives goal text only when enabled.')),
        const Divider(),
        Text('Manage saved plans',
            style: Theme.of(context).textTheme.titleLarge),
        ...state.plans.map((p) => ListTile(
            title: Text(p.title),
            trailing: IconButton(
                tooltip: 'Delete plan',
                icon: const Icon(Icons.delete_outline),
                onPressed: state.offline
                    ? null
                    : () async {
                        final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                                    title: const Text('Delete this plan?'),
                                    content: const Text(
                                        'This removes the plan and its tasks from your local backend.'),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel')),
                                      FilledButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Delete'))
                                    ]));
                        if (confirmed == true) {
                          try {
                            await state.delete(p);
                          } catch (e) {
                            if (context.mounted) {
                              message(context, e.toString());
                            }
                          }
                        }
                      }))),
        const SizedBox(height: 16),
        const EmptyCard('TaskPilot AI • 1.0',
            'Built by Abu Hurrairah. Turn goals into action. Local demo user, no account required.',
            icon: Icons.route_rounded)
      ]);
}
