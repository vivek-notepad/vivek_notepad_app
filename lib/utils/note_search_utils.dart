bool noteMatchesSearch(Map<String, dynamic> data, String query) {
  final trimmed = query.trim().toLowerCase();
  if (trimmed.isEmpty) return true;

  final title = (data['title'] ?? '').toString().toLowerCase();
  final content = (data['content'] ?? '').toString().toLowerCase();
  if (title.contains(trimmed) || content.contains(trimmed)) return true;

  final tasks = data['tasks'] as List<dynamic>?;
  if (tasks != null) {
    for (final task in tasks) {
      final text = (task['text'] ?? '').toString().toLowerCase();
      if (text.contains(trimmed)) return true;
    }
  }
  return false;
}
