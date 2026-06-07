import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';
import '../utils/pin_storage.dart';

enum PinMode { unlock, setup, confirm }

class PinScreen extends StatefulWidget {
  final PinMode mode;
  final String? confirmPin; // diisi saat mode == confirm
  final String title;
  final String subtitle;

  const PinScreen({
    super.key,
    this.mode = PinMode.unlock,
    this.confirmPin,
    this.title = 'Masukkan PIN',
    this.subtitle = 'Masukkan PIN 6 digit untuk membuka Zerro',
  });

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen>
    with SingleTickerProviderStateMixin {
  String _pin = '';
  String? _errorMsg;
  bool _isLoading = false;

  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _onKey(String digit) {
    if (_pin.length >= 6 || _isLoading) return;
    HapticFeedback.lightImpact();
    setState(() {
      _pin += digit;
      _errorMsg = null;
    });
    if (_pin.length == 6) _submit();
  }

  void _onDelete() {
    if (_pin.isEmpty || _isLoading) return;
    HapticFeedback.lightImpact();
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);

    // Sedikit delay agar dot terakhir terlihat terisi
    await Future.delayed(const Duration(milliseconds: 150));

    switch (widget.mode) {
      case PinMode.unlock:
        final ok = await PinStorage.verify(_pin);
        if (!mounted) return;
        if (ok) {
          Navigator.of(context).pop(true);
        } else {
          _shake('PIN salah, coba lagi');
        }
        break;

      case PinMode.setup:
        // Lanjut ke layar konfirmasi
        if (!mounted) return;
        final confirmed = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PinScreen(
              mode: PinMode.confirm,
              confirmPin: _pin,
              title: 'Konfirmasi PIN',
              subtitle: 'Masukkan ulang PIN yang sama',
            ),
          ),
        );
        if (!mounted) return;
        if (confirmed == true) {
          Navigator.of(context).pop(true);
        } else {
          _shake('PIN tidak cocok, ulangi');
        }
        break;

      case PinMode.confirm:
        if (!mounted) return;
        if (_pin == widget.confirmPin) {
          await PinStorage.setPin(_pin);
          if (!mounted) return;
          Navigator.of(context).pop(true);
        } else {
          _shake('PIN tidak cocok, ulangi');
        }
        break;
    }
  }

  void _shake(String msg) {
    setState(() {
      _pin = '';
      _errorMsg = msg;
      _isLoading = false;
    });
    _shakeCtrl.forward(from: 0);
    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Back button (hanya untuk setup/confirm)
            if (widget.mode != PinMode.unlock)
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppTheme.textSecondary,
                  ),
                  onPressed: () => Navigator.pop(context, false),
                ),
              )
            else
              const SizedBox(height: 16),

            const Spacer(),

            // Logo
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                'assets/images/logo.png',
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.shield_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              widget.title,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textHint,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            // Hint PIN default — hanya tampil saat mode unlock
            if (widget.mode == PinMode.unlock) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(10),
                  border: const Border.fromBorderSide(
                    BorderSide(color: AppTheme.border, width: 1),
                  ),
                ),
                child: const Text(
                  'PIN default: 000000',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 40),

            // PIN dots
            AnimatedBuilder(
              animation: _shakeAnim,
              builder: (_, child) {
                final offset = _shakeCtrl.isAnimating
                    ? _shakeAnim.value * 8
                    : 0.0;
                return Transform.translate(
                  offset: Offset(
                    offset * ((_shakeAnim.value * 10).round().isEven ? 1 : -1),
                    0,
                  ),
                  child: child,
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (i) {
                  final filled = i < _pin.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled ? AppTheme.primary : Colors.transparent,
                      border: Border.all(
                        color: filled ? AppTheme.primary : AppTheme.textHint,
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Error message
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _errorMsg != null
                  ? Padding(
                      key: ValueKey(_errorMsg),
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        _errorMsg!,
                        style: const TextStyle(
                          color: AppTheme.danger,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : const SizedBox(height: 36),
            ),

            const Spacer(),

            // Numpad
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
              child: Column(
                children: [
                  _numRow(['1', '2', '3']),
                  const SizedBox(height: 12),
                  _numRow(['4', '5', '6']),
                  const SizedBox(height: 12),
                  _numRow(['7', '8', '9']),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(width: 80), // placeholder
                      _numButton('0'),
                      _deleteButton(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _numRow(List<String> digits) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: digits.map(_numButton).toList(),
  );

  Widget _numButton(String digit) => GestureDetector(
    onTap: () => _onKey(digit),
    child: Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        shape: BoxShape.circle,
        border: const Border.fromBorderSide(
          BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      child: Center(
        child: Text(
          digit,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ),
  );

  Widget _deleteButton() => GestureDetector(
    onTap: _onDelete,
    child: Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.backspace_outlined,
          color: AppTheme.textSecondary,
          size: 26,
        ),
      ),
    ),
  );
}
