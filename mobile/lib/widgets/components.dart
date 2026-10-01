import 'package:flutter/material.dart';
import '../models/plan.dart';

const pilotPurple = Color(0xFF6655D8);
void message(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

class PageBody extends StatelessWidget {
  final List<Widget> children;
  const PageBody({super.key, required this.children});
  @override
  Widget build(BuildContext context) => Center(
      child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: children)));
}

class SectionTitle extends StatelessWidget {
  final String title, subtitle;
  const SectionTitle(this.title, this.subtitle, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(subtitle, style: Theme.of(context).textTheme.bodyLarge)
      ]));
}

class EmptyCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Widget? action;
  const EmptyCard(this.title, this.subtitle,
      {super.key, this.icon = Icons.checklist_rounded, this.action});
  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(children: [
            Icon(icon, size: 48, color: pilotPurple),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 20), action!]
          ])));
}

class Metric extends StatelessWidget {
  final String value, label;
  const Metric(this.value, this.label, {super.key});
  @override
  Widget build(BuildContext context) => Expanded(
      child: Card(
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
              child: Column(children: [
                Text(value,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(label, textAlign: TextAlign.center)
              ]))));
}

class TaskCard extends StatelessWidget {
  final PilotTask task;
  final VoidCallback? onToggle, onEdit;
  const TaskCard(this.task, {super.key, this.onToggle, this.onEdit});
  @override
  Widget build(BuildContext context) {
    final color = task.priority == 'high'
        ? const Color(0xFFC06038)
        : task.priority == 'medium'
            ? pilotPurple
            : const Color(0xFF258673);
    return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
            padding: const EdgeInsets.all(12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (onToggle != null)
                  Checkbox(
                      value: task.completed, onChanged: (_) => onToggle!()),
                Expanded(
                    child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(task.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    decoration: task.completed
                                        ? TextDecoration.lineThrough
                                        : null)))),
                if (onEdit != null)
                  IconButton(
                      tooltip: 'Edit task',
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 18))
              ]),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 6, children: [
                Chip(
                    label: Text(task.priority.toUpperCase(),
                        style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.bold))),
                Chip(
                    avatar: const Icon(Icons.schedule, size: 16),
                    label: Text('${task.minutes} min')),
                Chip(label: Text('Day ${task.day}')),
                Chip(label: Text(task.category))
              ]),
              ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(bottom: 8),
                  title: Text('${task.subtasks.length} steps',
                      style: Theme.of(context).textTheme.bodyMedium),
                  subtitle: Text(task.description,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  children: task.subtasks
                      .map((s) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.subdirectory_arrow_right,
                                    size: 18),
                                const SizedBox(width: 8),
                                Expanded(child: Text(s))
                              ])))
                      .toList())
            ])));
  }
}
