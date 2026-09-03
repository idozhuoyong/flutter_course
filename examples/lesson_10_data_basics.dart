void main(List<String> arguments) {
  const maxTitleLength = 80;
  const tags = <String>['Flutter', 'iOS'];

  var draftTitle = arguments.isEmpty ? '  整理 Flutter 笔记  ' : arguments.first;
  final String? draftNote = arguments.length > 1 ? arguments[1] : null;
  var isCompleted = false;
  final priority = 2;
  final estimateHours = 1.5;

  draftTitle = draftTitle.trim();
  final title = draftTitle;
  final note = draftNote?.trim();
  final displayNote = note == null || note.isEmpty ? '无补充说明' : note;

  if (title.isEmpty || title.length > maxTitleLength) {
    throw StateError('标题长度必须在 1～$maxTitleLength 个字符之间');
  }

  print('标题：$title');
  print('说明：$displayNote');
  print('优先级：$priority');
  print('预计用时：$estimateHours 小时');
  print('完成状态：$isCompleted');
  print('标签：${tags.join('、')}');

  isCompleted = true;
  print('更新后完成状态：$isCompleted');

  // 临时取消任意一行的注释，再运行 dart analyze 观察类型错误。
  // draftTitle = 42;
  // priority = 3;
  // const invalidValue = DateTime.now();
  // final invalidLength = draftNote.length;
}
