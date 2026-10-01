import 'package:flutter/material.dart';
import '../models/plan.dart';
import '../state/app_state.dart';
import '../widgets/components.dart';

class TasksScreen extends StatefulWidget {
  final AppState state;
  const TasksScreen(this.state, {super.key});
  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String search = '', filter = 'All';
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

  Future<void> edit(PilotTask task) async {
    final controller = TextEditingController(text: task.title);
    final text = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Edit task'),
                content: TextField(
                    controller: controller, maxLength: 200, autofocus: true),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () {
                        if (controller.text.trim().isNotEmpty) {
                          Navigator.pop(context, controller.text.trim());
                        }
                      },
                      child: const Text('Save'))
                ]));
    // Dispose after the dialog's closing animation has finished.
    Future.delayed(const Duration(milliseconds: 400), controller.dispose);
    if (text != null) {
      try {
        await widget.state.edit(task, text);
      } catch (e) {
        if (mounted) {
          message(context, e.toString());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final tasks = state.tasks
        .where((t) =>
            t.title.toLowerCase().contains(search.toLowerCase()) &&
            (filter == 'All' ||
                (filter == 'Open' && !t.completed) ||
                (filter == 'Done' && t.completed) ||
                (filter == 'High' && t.priority == 'high')))
        .toList();
    return RefreshIndicator(
        onRefresh: state.reload,
        child: PageBody(children: [
          const SectionTitle('Small steps.\nReal progress.',
              'Your saved tasks, ready when you are.'),
          LinearProgressIndicator(
              value: state.progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8)),
          const SizedBox(height: 8),
          Text('${state.completed}/${state.tasks.length} complete'),
          const SizedBox(height: 20),
          TextField(
              onChanged: (v) => setState(() => search = v),
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search), hintText: 'Find a task')),
          const SizedBox(height: 12),
          Wrap(
              spacing: 8,
              children: ['All', 'Open', 'Done', 'High']
                  .map((f) => ChoiceChip(
                      label: Text(f),
                      selected: filter == f,
                      onSelected: (_) => setState(() => filter = f)))
                  .toList()),
          const SizedBox(height: 20),
          if (tasks.isEmpty)
            const EmptyCard('No tasks here yet',
                'Create and save a plan, or try a different filter.'),
          ...tasks.map((t) => TaskCard(t,
              onToggle: state.offline || updating.contains(t.id)
                  ? null
                  : () => toggle(t),
              onEdit: state.offline ? null : () => edit(t)))
        ]));
  }
}
