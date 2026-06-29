import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_bloc_observer.dart';
import 'injection/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = const AppBlocObserver();

  await Firebase.initializeApp();

  await di.init();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(const DompetKampusApp());
}

class DompetKampusApp extends StatefulWidget {
  const DompetKampusApp({super.key});

  @override
  State<DompetKampusApp> createState() => _DompetKampusAppState();
}

class _DompetKampusAppState extends State<DompetKampusApp> {
  final _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Cold start: app dibuka dari deep link
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) _handleDeepLink(initialUri);

      // Warm start: app sudah berjalan, terima deep link baru
      _appLinks.uriLinkStream.listen(_handleDeepLink);
    });
  }

  void _handleDeepLink(Uri uri) {
    if (uri.scheme == 'dkg' && uri.host == 'checkout') {
      AppRouter.router.go('/merchant', extra: {
        'storeName': uri.queryParameters['store'] ?? 'Hydraulic Store',
        'orderId': uri.queryParameters['order'] ?? '',
        'amount': double.tryParse(uri.queryParameters['amount'] ?? '0') ?? 0.0,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Dompet Kampus Global',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
    );
  }
}
