import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config.dart';
import '../models/plan.dart';
import '../services/api_service.dart';
import '../services/revenue_cat_service.dart';

class AppState extends ChangeNotifier {
  final api = ApiService();
  final revenue = RevenueCatService();
  late SharedPreferences prefs;
  List<PilotPlan> plans = [];
  bool onboarded = false, dark = false, loading = true, offline = false;
  String? error;
  int generations = 0;
  bool get pro => revenue.isPro;
  bool get canGenerate => pro || generations < AppConfig.freeLimit;
  List<PilotTask> get tasks => plans.expand((p) => p.tasks).toList();
  List<PilotTask> get todayTasks => plans
      .expand(
          (p) => p.tasks.where((t) => !t.completed && t.day <= p.currentDay))
      .toList();
  int get completed => tasks.where((t) => t.completed).length;
  double get progress => tasks.isEmpty ? 0 : completed / tasks.length;
  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
    onboarded = prefs.getBool('onboarded') ?? false;
    dark = prefs.getBool('dark') ?? false;
    generations = prefs.getInt('generations') ?? 0;
    try {
      final cache = prefs.getString('plans');
      if (cache != null) {
        plans = (jsonDecode(cache) as List)
            .map((j) => PilotPlan.fromJson(Map<String, dynamic>.from(j as Map)))
            .toList();
      }
    } catch (_) {
      plans = [];
    }
    revenue.addListener(notifyListeners);
    // Billing errors never prevent the core app from opening.
    await Future.wait([reload(), revenue.initialize()]);
    loading = false;
    notifyListeners();
  }

  Future<void> reload() async {
    try {
      final fetched = await api.list();
      plans = fetched;
      offline = false;
      error = null;
      await prefs.setString(
          'plans', jsonEncode(plans.map((p) => p.toJson()).toList()));
    } catch (e) {
      offline = true;
      error = e.toString();
    }
    notifyListeners();
  }

  Future<void> finishOnboarding() async {
    onboarded = true;
    await prefs.setBool('onboarded', true);
    notifyListeners();
  }

  Future<void> setDark(bool value) async {
    dark = value;
    await prefs.setBool('dark', value);
    notifyListeners();
  }

  Future<PilotPlan> generate(String goal, int days) async {
    if (!canGenerate) {
      throw Exception('Free limit reached. Open Pro for unlimited generation.');
    }
    final plan = await api.generate(goal, days, pro);
    generations += 1;
    await prefs.setInt('generations', generations);
    notifyListeners();
    return plan;
  }

  Future<void> save(PilotPlan draft, String goal) async {
    await api.save(draft, goal);
    await reload();
  }

  Future<void> toggle(PilotTask task) async {
    await api.toggle(task);
    await reload();
  }

  Future<void> edit(PilotTask task, String title) async {
    await api.edit(task, title);
    await reload();
  }

  Future<void> delete(PilotPlan plan) async {
    await api.delete(plan);
    await reload();
  }

  @override
  void dispose() {
    revenue.removeListener(notifyListeners);
    revenue.dispose();
    super.dispose();
  }
}
