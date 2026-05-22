import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/observability/sentry_observability.dart';

Future<void> main() async {
  await runLanggengClipApp(app: const ProviderScope(child: LanggengClipApp()));
}
