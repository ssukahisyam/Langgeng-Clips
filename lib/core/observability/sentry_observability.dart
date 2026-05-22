import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

const _sentryDsn = String.fromEnvironment('SENTRY_DSN');

Future<void> runLanggengClipApp({required Widget app}) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (_sentryDsn.isEmpty) {
    runApp(app);
    return;
  }

  await SentryFlutter.init((options) {
    options.dsn = _sentryDsn;
    options.sendDefaultPii = false;
    options.attachStacktrace = true;
    options.environment = kReleaseMode ? 'production' : 'debug';
    options.beforeSend = (event, hint) async => scrubSentryEvent(event);
    options.beforeBreadcrumb = scrubSentryBreadcrumb;
  }, appRunner: () => runApp(app));
}

SentryEvent scrubSentryEvent(SentryEvent event) {
  final message = event.message;
  if (message != null) {
    event.message = SentryMessage(sanitizeTelemetry(message.formatted));
  }
  final request = event.request;
  if (request != null) {
    event.request = scrubSentryRequest(request);
  }
  event.breadcrumbs = event.breadcrumbs?.map(_scrubBreadcrumb).toList();
  return event;
}

SentryRequest scrubSentryRequest(SentryRequest request) {
  return SentryRequest(
    url: request.url == null ? null : sanitizeTelemetry(request.url!),
    method: request.method,
    queryString: request.queryString == null
        ? null
        : sanitizeTelemetry(request.queryString!),
    cookies: request.cookies,
    fragment: request.fragment,
    apiTarget: request.apiTarget,
    data: request.data == null
        ? null
        : sanitizeTelemetry(request.data.toString()),
    headers: request.headers,
    env: request.env,
  );
}

Breadcrumb? scrubSentryBreadcrumb(Breadcrumb? breadcrumb, Hint hint) {
  if (breadcrumb == null) {
    return null;
  }

  return _scrubBreadcrumb(breadcrumb);
}

Breadcrumb _scrubBreadcrumb(Breadcrumb breadcrumb) {
  breadcrumb.message = breadcrumb.message == null
      ? null
      : sanitizeTelemetry(breadcrumb.message!);
  breadcrumb.data = breadcrumb.data?.map(
    (key, value) => MapEntry(key, sanitizeTelemetry(value.toString())),
  );
  return breadcrumb;
}

String sanitizeTelemetry(String value) {
  return value
      .replaceAll(RegExp(r'gsk_[A-Za-z0-9_-]+'), '[REDACTED_GROQ_KEY]')
      .replaceAllMapped(
        RegExp(
          r'(api[_-]?key|authorization|bearer)[:= ]+[^\s,]+',
          caseSensitive: false,
        ),
        (match) => '${match.group(1)}=[REDACTED_SECRET]',
      )
      .replaceAll(RegExp(r'content://[^\s]+'), '[REDACTED_CONTENT_URI]')
      .replaceAll(RegExp(r'file://[^\s]+'), '[REDACTED_FILE_URI]')
      .replaceAll(
        RegExp(r'(/storage|/sdcard|/data)/[^\s]+'),
        '[REDACTED_PATH]',
      );
}
