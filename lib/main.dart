import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app.dart';
import 'core/utils/fullscreen_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // 初始化 IANA 时区数据库
  tz_data.initializeTimeZones();

  // 加载环境变量
  await dotenv.load(fileName: '.env');

  runApp(const ProviderScope(child: App()));

  WidgetsBinding.instance.addPostFrameCallback((_) {
    enterFullscreen();
  });
}
