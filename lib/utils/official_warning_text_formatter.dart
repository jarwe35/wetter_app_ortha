class OfficialWarningTextFormatter {
  const OfficialWarningTextFormatter._();

  static String sanitize(String value) {
    if (value.trim().isEmpty) {
      return '';
    }

    var result = value
        .replaceAll(RegExp(r'<\s*br\s*/?\s*>', caseSensitive: false), '\n')
        .replaceAll(
          RegExp(
            r'</\s*(p|div|li|h1|h2|h3|h4|h5|h6)\s*>',
            caseSensitive: false,
          ),
          '\n',
        )
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll(RegExp(r'\*{5,}'), '');

    result = result
        .split('\n')
        .map((line) {
          return line.replaceAll(RegExp(r'[ \t]+'), ' ').trim();
        })
        .join('\n');

    result = result.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return result.trim();
  }

  static String summary(String value, {int maximumLength = 520}) {
    final cleaned = sanitize(value);

    if (cleaned.isEmpty || cleaned.length <= maximumLength) {
      return cleaned;
    }

    final paragraphs = cleaned
        .split(RegExp(r'\n+'))
        .map((paragraph) => paragraph.trim())
        .where((paragraph) => paragraph.isNotEmpty)
        .toList();

    final buffer = StringBuffer();

    for (final paragraph in paragraphs) {
      final additionalLength = paragraph.length + (buffer.isEmpty ? 0 : 2);

      if (buffer.length + additionalLength > maximumLength) {
        break;
      }

      if (buffer.isNotEmpty) {
        buffer.write('\n\n');
      }

      buffer.write(paragraph);
    }

    if (buffer.isNotEmpty) {
      return '${buffer.toString().trim()} …';
    }

    return _truncateAtSentence(cleaned, maximumLength);
  }

  static String _truncateAtSentence(String value, int maximumLength) {
    final candidate = value.substring(0, maximumLength);

    final sentenceEnd = [
      candidate.lastIndexOf('.'),
      candidate.lastIndexOf('!'),
      candidate.lastIndexOf('?'),
    ].reduce((first, second) => first > second ? first : second);

    if (sentenceEnd >= maximumLength ~/ 2) {
      return '${candidate.substring(0, sentenceEnd + 1).trim()} …';
    }

    final lastSpace = candidate.lastIndexOf(' ');

    if (lastSpace > 0) {
      return '${candidate.substring(0, lastSpace).trim()} …';
    }

    return '${candidate.trim()} …';
  }
}
