import 'package:flutter/material.dart';
import 'package:vboxes/core/colors/vaxp_colors.dart';
import 'package:vboxes/core/di/injection_container.dart';
import 'package:window_manager/window_manager.dart';
import 'core/theme/vaxp_theme.dart';
import 'package:venom_config/venom_config.dart';
import 'presentation/pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize config system
  await VenomConfig().init();

  // Initialize color listeners
  VaxpColors.init();

  // Initialize Dependency Injection
  setupDependencies();

  // Initialize window manager for desktop
  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(1100, 720),
    minimumSize: Size(800, 600),
    center: true,
    titleBarStyle: TitleBarStyle.hidden,
    title: 'VM Manager – VAXP',
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const VaxpApp());
}

class VaxpApp extends StatelessWidget {
  const VaxpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: VaxpTheme.dark,
      home: const HomePage(),
    );
  }
}

