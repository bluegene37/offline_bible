import 'dart:async';

import 'package:flutter/foundation.dart';

/// Single funnel for every uncaught error in the app.
///
/// Nothing here talks to a crash-reporting backend yet — wiring one up is a
/// matter of filling in [_forwardToReporter]. The point of routing everything
/// through one place first is that release builds stop swallowing failures
/// silently: without these handlers a build error in a widget shows the user a
/// blank grey box and tells us nothing at all.
class ErrorReporter {
  const ErrorReporter._();

  /// Installs the framework and platform error handlers. Call once, before
  /// [runApp]. [appRunner] is invoked inside a guarded zone so errors thrown
  /// from bare async callbacks are captured too.
  static void install(void Function() appRunner) {
    final previousOnError = FlutterError.onError;

    FlutterError.onError = (details) {
      // Keep the default console dump in debug; it is far more useful than
      // anything we would print ourselves.
      previousOnError?.call(details);
      _forwardToReporter(
        details.exception,
        details.stack,
        context: details.context?.toDescription(),
        fatal: false,
      );
    };

    // Errors that escape the framework entirely (platform channels, bare
    // async gaps). Returning true marks them handled so the process survives.
    PlatformDispatcher.instance.onError = (error, stack) {
      _forwardToReporter(error, stack, fatal: true);
      return true;
    };

    runZonedGuarded(appRunner, (error, stack) {
      _forwardToReporter(error, stack, fatal: true);
    });
  }

  /// Report a caught, non-fatal error that the app recovered from. Use this
  /// where a `catch` swallows something the user cannot act on.
  static void recordHandled(Object error, StackTrace? stack,
      {String? context}) {
    _forwardToReporter(error, stack, context: context, fatal: false);
  }

  static void _forwardToReporter(
    Object error,
    StackTrace? stack, {
    String? context,
    required bool fatal,
  }) {
    // TODO(release): forward to Crashlytics/Sentry here. Until a reporter is
    // configured, at least make the failure visible in `flutter logs` and in
    // device logs from a release build.
    debugPrint(
      '[${fatal ? 'FATAL' : 'ERROR'}]${context == null ? '' : ' ($context)'} $error',
    );
    if (stack != null) debugPrintStack(stackTrace: stack);
  }
}
