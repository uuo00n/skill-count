import 'package:universal_html/html.dart' as html;

Future<void> enterFullscreenImpl() async {
  final element = html.document.documentElement;
  if (element == null) return;
  element.requestFullscreen();
}
