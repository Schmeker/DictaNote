String firstLineOf(String plain) {
  final line = plain.trim().split('\n').first;
  return line.isEmpty ? '(leer)' : line;
}

String formatDateShort(DateTime dt) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(dt.day)}.${two(dt.month)}.${dt.year} ${two(dt.hour)}:${two(dt.minute)}';
}
