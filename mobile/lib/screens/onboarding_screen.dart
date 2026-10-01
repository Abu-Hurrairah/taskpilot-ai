import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../widgets/components.dart';

class OnboardingScreen extends StatelessWidget {
  final AppState state;
  const OnboardingScreen(this.state, {super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
          body: SafeArea(
              child: PageBody(children: [
        const SizedBox(height: 36),
        const Text('TASKPILOT AI',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: pilotPurple,
                fontWeight: FontWeight.w800,
                letterSpacing: 3)),
        const SizedBox(height: 48),
        Container(
            height: 160,
            decoration: BoxDecoration(
                color: pilotPurple.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(40)),
            child:
                const Icon(Icons.route_rounded, color: pilotPurple, size: 96)),
        const SizedBox(height: 36),
        const SectionTitle('Big goals.\nClear next steps.',
            'A calmer way to plan your day. Turn scattered ideas into a practical plan you can actually follow.'),
        const ListTile(
            leading: Icon(Icons.auto_awesome, color: pilotPurple),
            title: Text('Describe it naturally'),
            subtitle: Text('No perfect prompts or complicated setup.')),
        const ListTile(
            leading: Icon(Icons.checklist, color: pilotPurple),
            title: Text('Get a practical breakdown'),
            subtitle:
                Text('Tasks, priorities, time estimates and daily steps.')),
        const ListTile(
            leading: Icon(Icons.lock_outline, color: pilotPurple),
            title: Text('Start free, without an AI key'),
            subtitle: Text(
                'Local rule-based planning. Your goals stay on your own backend.')),
        const SizedBox(height: 24),
        FilledButton(
            onPressed: state.finishOnboarding,
            child: const Padding(
                padding: EdgeInsets.all(14), child: Text('Let’s make a plan'))),
        const SizedBox(height: 12),
        const Text('No account required • Made for focused action',
            textAlign: TextAlign.center)
      ])));
}
