import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

abstract class PlatformUtil {
  static bool get isWeb => kIsWeb;
  static bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  static bool get isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;

  static bool get canUseBiometrics => isMobile;
  static bool get canUseGeolocation => !isWeb;
  static bool get canUseDeviceInfo => !isWeb;
  static bool get canUseLocalStorage => true;
  static bool get canUseCamera => isMobile;
  static bool get canShare =>
      isMobile || (isWeb && false);
}
