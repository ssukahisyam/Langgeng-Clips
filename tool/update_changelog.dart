import 'dart:io';

void main(List<String> args) {
  final message = args.join(' ').trim();
  if (message.isEmpty) {
    stderr.writeln('Usage: dart run tool/update_changelog.dart <entry>');
    exitCode = 64;
    return;
  }

  final changelog = File('CHANGELOG.md');
  if (!changelog.existsSync()) {
    stderr.writeln('CHANGELOG.md not found.');
    exitCode = 66;
    return;
  }

  final content = changelog.readAsStringSync();
  const marker = '### Added\n\n';
  final index = content.indexOf(marker);
  if (index == -1) {
    stderr.writeln('Could not find the [Unreleased] Added section.');
    exitCode = 65;
    return;
  }

  final entry = '- $message\n';
  if (content.contains(entry)) {
    stdout.writeln('Changelog entry already exists.');
    return;
  }

  final insertAt = index + marker.length;
  changelog.writeAsStringSync(content.replaceRange(insertAt, insertAt, entry));
  stdout.writeln('Added changelog entry: $message');
}
