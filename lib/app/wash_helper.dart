import 'package:linksoap/core/storage.dart';
import 'package:linksoap/core/washer.dart';

String processText(String text, Storage storage) {
  final washer = Washer(
    detergents: storage.loadDetergents(),
    softeners: storage.loadSofteners(),
  );
  final cleaned = washer.wash(text);

  if (cleaned != text) {
    storage.incrementCleanedCount();
    if (storage.isHistoryEnabled()) {
      storage.addToHistory(text, cleaned);
    }
  }

  return cleaned;
}