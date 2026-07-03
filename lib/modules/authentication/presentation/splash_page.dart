// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ithinkwash/core/app_constants.dart';
import 'package:ithinkwash/core/theme_app.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
// Cargar la data inicial
    for (int i = 0; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 5));
      setState(() {
        _progress = i / 100;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeApp.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.water_drop,
              size: 100,
              color: ThemeApp.baseText,
            ),
            const SizedBox(height: 24),
            Text(
              AppConstants.APP_NAME,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: ThemeApp.baseText,
                    fontFamily: ThemeApp.fontFamily,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              "Cargando información...",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ThemeApp.baseText,
                    fontFamily: ThemeApp.fontFamily,
                  ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.white24,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(ThemeApp.baseText),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text("${(_progress * 100).toInt()}%",
                style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
