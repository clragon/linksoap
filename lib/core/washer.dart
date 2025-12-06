import 'package:linksoap/detergent/model.dart';
import 'package:linksoap/softener/model.dart';
import 'package:logging/logging.dart';

/// A machine for cleaning URLs.
class Washer {
  static final _log = Logger('Washer');

  /// Creates a new [Washer] with the given [detergents] and [softeners].
  const Washer({
    required this.detergents,
    required this.softeners,
  });

  /// The detergents to apply to URLs given to this [Washer].
  final List<Detergent> detergents;

  /// The softeners to apply to URLs given to this [Washer].
  final List<Softener> softeners;

  /// Cleans the given [url] by applying softeners and detergents in order.
  /// If the input is not a valid URL, returns the input.
  String wash(String url) {
    _log.fine('wash: $url');
    Uri uri;
    try {
      uri = Uri.parse(url);
    } on FormatException {
      _log.fine('Invalid URL format, returning as-is');
      return url;
    }

    if (!uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) {
      _log.fine('Not an HTTP(S) URL, returning as-is');
      return url;
    }

    for (final softener in softeners) {
      if (!softener.enabled) continue;
      final pattern = RegExp(softener.domain);
      if (pattern.hasMatch(uri.host)) {
        final newHost = softener.replacement;
        _log.fine(
            'Applying softener: ${softener.name} (${uri.host} -> $newHost)');
        uri = uri.replace(host: newHost);
      }
    }

    for (final detergent in detergents) {
      if (!detergent.enabled) continue;
      if (!RegExp(detergent.domain).hasMatch(uri.host)) {
        continue;
      }

      if (detergent.rule.isEmpty) {
        continue;
      }

      final filteredParams = <String, String>{};
      for (final entry in uri.queryParameters.entries) {
        if (!RegExp(detergent.rule).hasMatch(entry.key)) {
          filteredParams[entry.key] = entry.value;
        }
      }

      if (filteredParams.length != uri.queryParameters.length) {
        final removedCount = uri.queryParameters.length - filteredParams.length;
        _log.fine(
            'Applying detergent: ${detergent.name} (removed $removedCount params)');
        uri = Uri(
          scheme: uri.scheme,
          userInfo: uri.userInfo.isEmpty ? null : uri.userInfo,
          host: uri.host,
          port: uri.hasPort ? uri.port : null,
          path: uri.path,
          queryParameters: filteredParams.isEmpty ? null : filteredParams,
          fragment: uri.fragment.isEmpty ? null : uri.fragment,
        );
      }
    }

    final result = uri.toString();
    _log.info('$url -> $result');
    return result;
  }
}
