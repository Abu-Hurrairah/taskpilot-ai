import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../widgets/components.dart';
import 'create_goal_screen.dart';
import 'plan_screen.dart';

class DashboardScreen extends StatelessWidget {
  final AppState state;
  final VoidCallback openPro;
  const DashboardScreen(this.state, this.openPro, {super.key});
  @override
  Widget build(BuildContext context) => RefreshIndicator(
      onRefresh: state.reload,
      child: PageBody(children: [
        Row(children: [
          const Icon(Icons.route_rounded, color: pilotPurple),
          const SizedBox(width: 8),
          const Text('YOUR FOCUS, SIMPLIFIED',
              style: TextStyle(
                  letterSpacing: 1.2,
                  fontSize: 11,
                  fontWeight: FontWeight.bold)),
          const Spacer(),
          Chip(label: Text(state.pro ? 'PRO' : 'FREE'))
        ]),
        const SizedBox(height: 20),
        const SectionTitle('Turn goals\ninto action.',
            'A clear plan for everything on your mind. Start small. Keep moving.'),
        Card(
            color: pilotPurple,
            child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('What do you want to get done?',
                          style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 8),
                      const Text('From scattered ideas to your next best step.',
                          style: TextStyle(color: Colors.white)),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                          style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: pilotPurple),
                          onPressed: () {
                            if (!state.canGenerate) {
                              openPro();
                              return;
                            }
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => CreateGoalScreen(state)));
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Create a plan'))
                    ]))),
        const SizedBox(height: 16),
        Row(children: [
          Metric('${state.plans.length}', 'Plans'),
          Metric('${state.completed}', 'Done'),
          Metric('${(state.progress * 100).round()}%', 'Progress')
        ]),
        const SizedBox(height: 16),
        Text('Your momentum', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        LinearProgressIndicator(
            value: state.progress,
            minHeight: 10,
            borderRadius: BorderRadius.circular(8)),
        const SizedBox(height: 8),
        Text('${state.completed} of ${state.tasks.length} tasks complete'),
        const SizedBox(height: 24),
        Text('Saved plans', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (state.plans.isEmpty)
          const EmptyCard('A fresh start',
              'Create your first plan to turn a big goal into achievable steps.'),
        ...state.plans.map((p) => Card(
            child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: const Icon(Icons.layers_outlined, color: pilotPurple),
                title: Text(p.title,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(
                    '${p.tasks.length} tasks • ${p.days} days • ${p.done} completed'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => PlanScreen(state, p)))))),
        const SizedBox(height: 12),
        if (!state.pro)
          TextButton(
              onPressed: openPro,
              child: const Text('Go further with TaskPilot Pro →'))
      ]));
}
