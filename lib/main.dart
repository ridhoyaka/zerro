import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/dashboard.dart';
import 'screens/pin_screen.dart';
import 'utils/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const PassVaultApp());
}

class PassVaultApp extends StatelessWidget {
  const PassVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zerro',
      theme: AppTheme.theme,
      home: const _AppGate(),
    );
  }
}

/// Gate: tampilkan PIN screen, baru masuk ke Dashboard setelah berhasil
class _AppGate extends StatefulWidget {
  const _AppGate();

  @override
  State<_AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<_AppGate> with WidgetsBindingObserver {
  bool _unlocked = false;
  DateTime? _backgroundedAt;

  // Kunci ulang jika app di-background lebih dari 30 detik
  static const _lockTimeout = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _showPin();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _backgroundedAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed && _unlocked) {
      final bg = _backgroundedAt;
      if (bg != null && DateTime.now().difference(bg) > _lockTimeout) {
        setState(() => _unlocked = false);
        _showPin();
      }
    }
  }

  Future<void> _showPin() async {
    // Tunggu frame pertama selesai render
    await Future.delayed(Duration.zero);
    if (!mounted) return;

    final ok = await Navigator.of(context).push<bool>(
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (context, anim, secondAnim) => const PinScreen(
          mode: PinMode.unlock,
          title: 'Masukkan PIN',
          subtitle: 'Masukkan PIN 6 digit untuk membuka Zerro',
        ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );

    if (ok == true && mounted) {
      setState(() => _unlocked = true);
    } else if (mounted) {
      // Jika user menekan back tanpa berhasil, tutup app
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_unlocked) {
      // Layar hitam sementara PIN belum terbuka
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: SizedBox.expand(),
      );
    }
    return const DashboardPage();
  }
}
