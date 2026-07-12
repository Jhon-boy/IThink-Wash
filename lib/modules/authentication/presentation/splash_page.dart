// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ithinkwash/core/app_constants.dart';
import 'package:ithinkwash/core/theme_app.dart';
import 'package:ithinkwash/modules/authentication/domain/providers/user_provider.dart';
import 'package:ithinkwash/modules/main/presentation/main_page.dart';
import 'package:ithinkwash/modules/ordenes/data/datasource/orden_remote_datasource.dart';
import 'package:ithinkwash/modules/ordenes/data/repository/orden_repository.dart';
import 'package:ithinkwash/modules/ordenes/domain/providers/orden_notifier.dart';
import 'package:ithinkwash/modules/ordenes/domain/repository/orden_repository.dart';
import 'package:ithinkwash/shared/widgets/dialog_widget.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  double _progress = 0.0;
  late final OrdenRepository repository;

  @override
  void initState() {
    super.initState();
    repository = OrdenRemoteRepository(
      OrdenRemoteDataSource(ref: ref),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final idSucursal =
        ref.read(userProvider.notifier).getUser()?.idSucursal ?? 1;

    for (int i = 0; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 5));
      if (mounted) {
        setState(() {
          _progress = i / 100;
        });
      }
    }

    final result = await repository.getOrdenesBySucursalEntity(idSucursal);

    result.fold(
      (failure) {
        if (mounted) {
          DialogHelper.error(context,
              message: 'Error al obtener las órdenes: ${failure.message}',
              onConfirmed: () {});
        }
      },
      (ordenes) {
        if (mounted) {
          ref.read(orderProvider.notifier).setOrdenes(ordenes);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const MainPage()));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeApp.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.water_drop, size: 100, color: ThemeApp.baseText),
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
