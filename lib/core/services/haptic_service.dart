import 'package:flutter/services.dart';

enum HapticType {
  selection,
  light,
  medium,
  heavy,
  success,
  warning,
  error,
}

abstract class HapticService {
  Future<void> trigger(HapticType type);
  void setEnabled(bool enabled);
}

class SystemHapticService implements HapticService {
  bool _enabled = true;

  @override
  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  @override
  Future<void> trigger(HapticType type) async {
    if (!_enabled) return;

    try {
      switch (type) {
        case HapticType.selection:
          await HapticFeedback.selectionClick();
          break;
        case HapticType.light:
          await HapticFeedback.lightImpact();
          break;
        case HapticType.medium:
          await HapticFeedback.mediumImpact();
          break;
        case HapticType.heavy:
        case HapticType.warning:
          await HapticFeedback.heavyImpact();
          break;
        case HapticType.success:
          await HapticFeedback.mediumImpact();
          break;
        case HapticType.error:
          await HapticFeedback.vibrate();
          break;
      }
    } catch (_) {
      // Gracefully handle devices without haptics
    }
  }
}
