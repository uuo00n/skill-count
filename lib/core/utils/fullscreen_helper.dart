import 'fullscreen_helper_io.dart'
    if (dart.library.html) 'fullscreen_helper_web.dart';

Future<void> enterFullscreen() => enterFullscreenImpl();
