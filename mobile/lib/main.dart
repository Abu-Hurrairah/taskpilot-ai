import 'package:flutter/material.dart';
import 'state/app_state.dart';
import 'widgets/components.dart';
import 'screens/onboarding_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/today_screen.dart';
import 'screens/pro_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TaskPilotApp());
}

class TaskPilotApp extends StatefulWidget {
  const TaskPilotApp({super.key});
  @override
  State<TaskPilotApp> createState() => _TaskPilotAppState();
}

class _TaskPilotAppState extends State<TaskPilotApp> {
  final state = AppState();
  int tab = 0;
  @override
  void initState() {
    super.initState();
    state.initialize();
  }

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }

  ThemeData theme(Brightness brightness) {
    final scheme =
        ColorScheme.fromSeed(seedColor: pilotPurple, brightness: brightness);
    return ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: brightness == Brightness.light
            ? const Color(0xFFF7F7FB)
            : const Color(0xFF11121B),
        appBarTheme: const AppBarTheme(
            centerTitle: false,
            backgroundColor: Colors.transparent,
            elevation: 0),
        cardTheme: CardThemeData(
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: brightness == Brightness.light
                ? Colors.white
                : const Color(0xFF20212D)),
        inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: scheme.surface,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: scheme.outlineVariant))),
        filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)))),
        chipTheme: ChipThemeData(
            side: BorderSide.none,
            backgroundColor: scheme.surfaceContainer,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))));
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: state,
      builder: (context, _) => MaterialApp(
          title: 'TaskPilot AI',
          debugShowCheckedModeBanner: false,
          theme: theme(Brightness.light),
          darkTheme: theme(Brightness.dark),
          themeMode: state.dark ? ThemeMode.dark : ThemeMode.light,
          home: state.loading
              ? const Scaffold(
                  body: Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.route_rounded, size: 72, color: pilotPurple),
                  SizedBox(height: 20),
                  Text('TaskPilot AI',
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  CircularProgressIndicator()
                ])))
              : !state.onboarded
                  ? OnboardingScreen(state)
                  : Scaffold(
                      appBar: AppBar(
                          title: const Text('TaskPilot AI',
                              style: TextStyle(fontWeight: FontWeight.w800)),
                          actions: [
                            IconButton(
                                tooltip: 'Refresh',
                                onPressed: state.reload,
                                icon: const Icon(Icons.refresh))
                          ]),
                      body: Column(children: [
                        if (state.offline)
                          MaterialBanner(
                              content: Text(state.error ??
                                  'Backend offline. Saved plans are available read-only.'),
                              leading: const Icon(Icons.cloud_off_outlined),
                              actions: [
                                TextButton(
                                    onPressed: state.reload,
                                    child: const Text('Retry'))
                              ]),
                        Expanded(
                            child: IndexedStack(index: tab, children: [
                          DashboardScreen(state, () => setState(() => tab = 3)),
                          TasksScreen(state),
                          TodayScreen(state, () => setState(() => tab = 3)),
                          ProScreen(state),
                          SettingsScreen(state)
                        ]))
                      ]),
                      bottomNavigationBar: NavigationBar(
                          selectedIndex: tab,
                          onDestinationSelected: (i) => setState(() => tab = i),
                          destinations: const [
                            NavigationDestination(
                                icon: Icon(Icons.home_outlined),
                                selectedIcon: Icon(Icons.home),
                                label: 'Home'),
                            NavigationDestination(
                                icon: Icon(Icons.checklist_outlined),
                                label: 'Tasks'),
                            NavigationDestination(
                                icon: Icon(Icons.wb_sunny_outlined),
                                label: 'Today'),
                            NavigationDestination(
                                icon: Icon(Icons.workspace_premium_outlined),
                                label: 'Pro'),
                            NavigationDestination(
                                icon: Icon(Icons.settings_outlined),
                                label: 'Settings')
                          ]))));
}
