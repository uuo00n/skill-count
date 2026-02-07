import 'dart:io';
import 'package:window_size/window_size.dart' as window_size;

Future<void> enterFullscreenImpl() async {
  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    final screen = await window_size.getCurrentScreen();
    if (screen == null) return;
    window_size.setWindowFrame(screen.frame);
  }
}
