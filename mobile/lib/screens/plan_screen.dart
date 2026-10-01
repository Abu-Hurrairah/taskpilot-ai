import 'package:flutter/material.dart';
import '../models/plan.dart';
import '../state/app_state.dart';
import '../widgets/components.dart';

class PlanScreen extends StatefulWidget {
  final AppState state;
  final PilotPlan plan;
  final String? sourceGoal;
  const PlanScreen(this.state, this.plan, {super.key, this.sourceGoal});
  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  bool saving = false;
  Future<void> save() async {
    setState(() => saving = true);
    try {
      await widget.state
          .save(widget.plan, widget.sourceGoal ?? widget.plan.title);
      if (mounted) {
        message(context, 'Plan saved. Your next steps are in Tasks and Today.');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        message(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: widget.state,
      builder: (context, _) {
        final matches = widget.state.plans.where((p) => p.id == widget.plan.id);
        final plan = widget.plan.id != null && matches.isNotEmpty
            ? matches.first
            : widget.plan;
        return Scaffold(
            appBar: AppBar(
                title: Text(
                    plan.id == null ? 'Your generated plan' : 'Plan details')),
            body: PageBody(children: [
              SectionTitle(plan.title, plan.summary),
              Wrap(spacing: 8, children: [
                Chip(
                    avatar: const Icon(Icons.auto_awesome, size: 16),
                    label: Text(plan.provider == 'local'
                        ? 'Local smart planner'
                        : 'Local Ollama LLM')),
                Chip(label: Text('${plan.days} days')),
                Chip(label: Text('${plan.minutes} min total'))
              ]),
              const SizedBox(height: 16),
              if (plan.id != null) ...[
                LinearProgressIndicator(
                    value: plan.progress,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(8)),
                const SizedBox(height: 8),
                Text('${plan.done}/${plan.tasks.length} tasks completed'),
                const SizedBox(height: 16)
              ],
              ...plan.tasks.map((t) => TaskCard(t,
                  onToggle: plan.id == null || widget.state.offline
                      ? null
                      : () async {
                          try {
                            await widget.state.toggle(t);
                          } catch (e) {
                            if (context.mounted) {
                              message(context, e.toString());
                            }
                          }
                        })),
              if (plan.id == null) ...[
                const SizedBox(height: 12),
                FilledButton.icon(
                    onPressed: saving ? null : save,
                    icon: saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.bookmark_add_outlined),
                    label: Text(saving ? 'Saving…' : 'Save this plan'))
              ]
            ]));
      });
}
