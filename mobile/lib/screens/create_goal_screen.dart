import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../widgets/components.dart';
import 'plan_screen.dart';

const demoGoal =
    'I need to finish my portfolio, prepare for an interview, apply to jobs, and complete my project this week.';

class CreateGoalScreen extends StatefulWidget {
  final AppState state;
  const CreateGoalScreen(this.state, {super.key});
  @override
  State<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends State<CreateGoalScreen> {
  final input = TextEditingController();
  final form = GlobalKey<FormState>();
  int days = 7;
  bool busy = false;
  String? error;
  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  Future<void> generate() async {
    if (!form.currentState!.validate()) {
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final plan = await widget.state.generate(input.text.trim(), days);
      if (!mounted) {
        return;
      }
      final saved = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
              builder: (_) => PlanScreen(widget.state, plan,
                  sourceGoal: input.text.trim())));
      if (saved == true && mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => error = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Create a plan')),
      body: PageBody(children: [
        const SectionTitle('What’s on your mind?',
            'Write it all down. We’ll turn the messy bits into clear, manageable steps.'),
        Form(
            key: form,
            child: TextFormField(
                controller: input,
                maxLines: 7,
                maxLength: 3000,
                enabled: !busy,
                decoration: const InputDecoration(
                    hintText:
                        'I need to prepare for an interview, finish my portfolio…',
                    alignLabelWithHint: true,
                    labelText: 'Your goal'),
                validator: (v) => v == null ||
                        v.trim().length < 5 ||
                        !RegExp(r'[a-zA-Z0-9]').hasMatch(v)
                    ? 'Describe a goal in at least 5 characters.'
                    : null)),
        Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
                onPressed: busy ? null : () => input.text = demoGoal,
                icon: const Icon(Icons.lightbulb_outline, size: 18),
                label: const Text('Use the demo goal'))),
        const SizedBox(height: 16),
        DropdownButtonFormField<int>(
            initialValue: days,
            decoration: const InputDecoration(labelText: 'Time horizon'),
            items: [1, 3, 7, 14, 30]
                .map((d) => DropdownMenuItem(
                    value: d, child: Text('$d ${d == 1 ? 'day' : 'days'}')))
                .toList(),
            onChanged: busy ? null : (d) => setState(() => days = d!)),
        const SizedBox(height: 20),
        Card(
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  const Icon(Icons.auto_awesome, color: pilotPurple),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(widget.state.pro
                          ? 'Pro: deeper breakdown with three steps per task.'
                          : 'Free: ${3 - widget.state.generations < 0 ? 0 : 3 - widget.state.generations} of 3 plan generations left on this installation.'))
                ]))),
        const SizedBox(height: 16),
        if (error != null)
          Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(error!,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.error))),
        FilledButton.icon(
            onPressed: busy || !widget.state.canGenerate ? null : generate,
            icon: busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.auto_awesome),
            label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                    busy ? 'Finding your next steps…' : 'Generate my plan'))),
        const SizedBox(height: 12),
        const Text('Time estimates are suggestions. No paid AI API is needed.',
            textAlign: TextAlign.center)
      ]));
}
