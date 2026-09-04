const maxTitleLength = 80;

String normalizeTitle(String value) {
  final title = value.trim();

  if (title.isEmpty || title.length > maxTitleLength) {
    throw StateError('标题长度必须在 1～$maxTitleLength 个字符之间');
  }

  return title;
}

String? normalizeNote(String? value) {
  final note = value?.trim();
  return note == null || note.isEmpty ? null : note;
}

class SparkIdea {
  SparkIdea({
    required String title,
    String? note,
    this.priority = 2,
    this.isCompleted = false,
  }) : title = normalizeTitle(title),
       note = normalizeNote(note) {
    if (priority < 1 || priority > 3) {
      throw RangeError.range(priority, 1, 3, 'priority');
    }
  }

  final String title;
  final String? note;
  final int priority;
  final bool isCompleted;

  String describe() {
    final displayNote = note ?? '无补充说明';

    return '标题：$title\n'
        '说明：$displayNote\n'
        '优先级：$priority\n'
        '完成状态：$isCompleted';
  }
}

void main(List<String> arguments) {
  final idea = SparkIdea(
    title: arguments.isEmpty ? '  整理 Flutter 笔记  ' : arguments.first,
    note: arguments.length > 1 ? arguments[1] : null,
  );

  print(idea.describe());

  // 临时取消任意一行的注释，再运行 dart analyze 观察参数错误。
  // SparkIdea();
  // SparkIdea(title: '学习 Dart', priority: null);
}
