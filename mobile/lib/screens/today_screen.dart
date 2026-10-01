import 'package:flutter/material.dart';
import '../models/plan.dart';
import '../state/app_state.dart';
import '../widgets/components.dart';

class TodayScreen extends StatefulWidget {
  final AppState state;
  final VoidCallback openPro;
  const TodayScreen(this.state, this.openPro, {super.key});
  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  int budget = 120;
  final Set<String> updating = {};
  Future<void> toggle(PilotTask task) async {
    if (updating.contains(task.id)) {
      return;
    }
    setState(() => updating.add(task.id));
    try {
      await widget.state.toggle(task);
    } catch (e) {
      if (mounted) {
        message(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => updating.remove(task.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    var tasks = List<PilotTask>.from(state.todayTasks);
    if (state.pro) {
      const rank = {'high': 0, 'medium': 1, 'low': 2};
      tasks.sort((a, b) => rank[a.priority]!.compareTo(rank[b.priority]!));
      int used = 0;
      tasks = tasks.where((t) {
        if (used + t.minutes <= budget) {
          used += t.minutes;
          return true;
        }
        return false;
      }).toList();
    }
    final effort = tasks.fold<int>(0, (s, t) => s + t.minutes);
    return PageBody(children: [
      const SectionTitle('Focus on today.',
          'A little direction goes a long way. Due and unfinished work appears here.'),
      if (state.pro) ...[
        Text('Your daily time budget: $budget minutes',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        Slider(
            value: budget.toDouble(),
            min: 30,
            max: 480,
            divisions: 15,
            label: '$budget min',
            onChanged: (v) => setState(() => budget = v.round()))
      ],
      Card(
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(children: [
                const Icon(Icons.wb_sunny_outlined,
                    color: pilotPurple, size: 36),
                const SizedBox(width: 16),
                Expanded(
                    child: Text('${tasks.length} next steps • $effort minutes',
                        style: Theme.of(context).textTheme.titleMedium))
              ]))),
      const SizedBox(height: 20),
      if (tasks.isEmpty)
        const EmptyCard('Room to breathe',
            'No unfinished tasks due today fit this view. Check Tasks for future work or increase your Pro time budget.',
            icon: Icons.wb_sunny_outlined),
      ...tasks.map((t) => TaskCard(t,
          onToggle: state.offline || updating.contains(t.id)
              ? null
              : () => toggle(t))),
      if (!state.pro)
        OutlinedButton.icon(
            onPressed: widget.openPro,
            icon: const Icon(Icons.workspace_premium_outlined),
            label: const Text('Pro: plan within a daily time budget')),
      if (state.pro) ...[
        const SizedBox(height: 16),
        Text('Your productivity insights',
            style: Theme.of(context).textTheme.titleLarge),
        Row(children: [
          Metric('${(state.progress * 100).round()}%', 'Completion'),
          Metric('${state.completed}', 'Tasks done')
        ]),
        Card(
            child: ListTile(
                leading: const Icon(Icons.schedule),
                title: Text(
                    '${state.tasks.where((t) => !t.completed).fold<int>(0, (sum, t) => sum + t.minutes)} minutes remaining'),
                subtitle: const Text(
                    'Across saved plans. Completion rate is a simple count, not a performance assessment.')))
      ]
    ]);
  }
}
