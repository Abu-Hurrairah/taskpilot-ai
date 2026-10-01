class PilotTask {
  final String id, title, description, priority, category;
  final int minutes, day;
  final List<String> subtasks;
  final bool completed;
  PilotTask.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        title = j['title'] as String,
        description = j['description'] as String? ?? '',
        priority = j['priority'] as String,
        category = j['category'] as String,
        minutes = j['estimated_minutes'] as int,
        day = j['suggested_day'] as int,
        subtasks = List<String>.from(j['subtasks'] as List),
        completed = j['completed'] as bool? ?? false;
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'priority': priority,
        'category': category,
        'estimated_minutes': minutes,
        'suggested_day': day,
        'subtasks': subtasks,
        'completed': completed
      };
}

class PilotPlan {
  final String? id;
  final String title, summary, provider;
  final int days;
  final DateTime? startDate;
  final List<PilotTask> tasks;
  PilotPlan.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String?,
        title = j['title'] as String,
        summary = j['summary'] as String,
        provider = j['provider'] as String,
        days = j['available_days'] as int,
        startDate = j['start_date'] == null
            ? null
            : DateTime.parse(j['start_date'] as String),
        tasks = (j['tasks'] as List)
            .map((t) => PilotTask.fromJson(Map<String, dynamic>.from(t as Map)))
            .toList();
  int get done => tasks.where((t) => t.completed).length;
  double get progress => tasks.isEmpty ? 0 : done / tasks.length;
  int get minutes => tasks.fold(0, (sum, t) => sum + t.minutes);
  Map<String, dynamic> toDraftJson() => {
        'title': title,
        'summary': summary,
        'provider': provider,
        'available_days': days,
        'tasks': tasks.map((t) => t.toJson()).toList()
      };
  Map<String, dynamic> toJson() =>
      {...toDraftJson(), 'id': id, 'start_date': startDate?.toIso8601String()};
  int get currentDay {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return startDate == null
        ? 1
        : today
                .difference(
                    DateTime(startDate!.year, startDate!.month, startDate!.day))
                .inDays +
            1;
  }
}
