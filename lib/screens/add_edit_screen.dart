import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/db_helper.dart';
import '../models/vault_entry.dart';
import '../utils/app_theme.dart';
import '../utils/field_definitions.dart';
import '../utils/password_generator.dart';
import '../widgets/strength_indicator.dart';

class AddEditScreen extends StatefulWidget {
  final VaultCategory category;
  final VaultEntry? existing;

  const AddEditScreen({super.key, required this.category, this.existing});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final DBHelper _db = DBHelper();

  late final TextEditingController _titleCtrl;
  late final Map<String, TextEditingController> _fieldCtrl;

  bool _isSaving = false;
  bool _obscurePassword = true;
  bool _obscureKodeKeamanan = true;

  int _genLength = 16;
  bool _genUpper = true;
  bool _genLower = true;
  bool _genDigits = true;
  bool _genSymbols = true;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.existing?.title ?? '');
    final defs = fieldsFor(widget.category);
    _fieldCtrl = {
      for (final key in defs.keys)
        key: TextEditingController(text: widget.existing?.fields[key] ?? ''),
    };
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    for (final c in _fieldCtrl.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final fields = {
      for (final e in _fieldCtrl.entries) e.key: e.value.text.trim(),
    };

    if (_isEditing) {
      await _db.update(
        widget.existing!.copyWith(
          title: _titleCtrl.text.trim(),
          fields: fields,
          updatedAt: DateTime.now(),
        ),
      );
    } else {
      await _db.insert(
        VaultEntry.create(
          title: _titleCtrl.text.trim(),
          category: widget.category,
          fields: fields,
        ),
      );
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  void _generatePassword(String fieldKey) {
    final generated = PasswordGenerator.generate(
      length: _genLength,
      useLower: _genLower,
      useUpper: _genUpper,
      useDigits: _genDigits,
      useSymbols: _genSymbols,
    );
    setState(() {
      _fieldCtrl[fieldKey]!.text = generated;
      _obscurePassword = false;
    });
  }

  void _showGeneratorSheet(String fieldKey) {
    int sheetLength = _genLength;
    bool sheetUpper = _genUpper;
    bool sheetLower = _genLower;
    bool sheetDigits = _genDigits;
    bool sheetSymbols = _genSymbols;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 28,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textHint,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Generator Password',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text(
                    'Panjang',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$sheetLength karakter',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Slider(
                value: sheetLength.toDouble(),
                min: 8,
                max: 32,
                divisions: 24,
                activeColor: AppTheme.primary,
                inactiveColor: AppTheme.surfaceHigh,
                onChanged: (v) => setSheet(() => sheetLength = v.round()),
              ),
              const Divider(height: 8),
              const SizedBox(height: 4),
              _toggle(
                'Huruf Besar (A-Z)',
                sheetUpper,
                (v) => setSheet(() => sheetUpper = v),
              ),
              _toggle(
                'Huruf Kecil (a-z)',
                sheetLower,
                (v) => setSheet(() => sheetLower = v),
              ),
              _toggle(
                'Angka (0-9)',
                sheetDigits,
                (v) => setSheet(() => sheetDigits = v),
              ),
              _toggle(
                r'Simbol (!@#$)',
                sheetSymbols,
                (v) => setSheet(() => sheetSymbols = v),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _genLength = sheetLength;
                      _genUpper = sheetUpper;
                      _genLower = sheetLower;
                      _genDigits = sheetDigits;
                      _genSymbols = sheetSymbols;
                    });
                    _generatePassword(fieldKey);
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Generate & Gunakan',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toggle(String label, bool value, ValueChanged<bool> onChanged) => Row(
    children: [
      Text(
        label,
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
      ),
      const Spacer(),
      Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.white,
        activeTrackColor: AppTheme.primary,
        inactiveTrackColor: AppTheme.surfaceHigh,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.categoryColor(widget.category);
    final defs = fieldsFor(widget.category);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          _isEditing
              ? 'Edit ${widget.category.label}'
              : 'Tambah ${widget.category.label}',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton(
                onPressed: _save,
                child: const Text(
                  'Simpan',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            // Category badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    AppTheme.categoryIcon(widget.category),
                    color: color,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.category.label,
                    style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Nama item
            _label('Nama Item'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'Beri nama untuk item ini',
                prefixIcon: Icon(Icons.label_rounded),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Nama item wajib diisi'
                  : null,
            ),
            const SizedBox(height: 20),

            // Dynamic fields
            ...defs.entries.map((e) => _buildField(e.key, e.value)),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String key, String label) {
    final ctrl = _fieldCtrl[key]!;

    // ── Catatan aman ──────────────────────────────────────────────────
    if (key == 'catatan') {
      return _fieldWrapper(
        label: label,
        child: TextFormField(
          controller: ctrl,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
            height: 1.5,
          ),
          maxLines: 8,
          minLines: 5,
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration(
            hintText: 'Tulis catatan di sini...',
            alignLabelWithHint: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Catatan wajib diisi' : null,
        ),
      );
    }

    // ── Password ──────────────────────────────────────────────────────
    if (key == 'password') {
      return _fieldWrapper(
        label: label,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: ctrl,
              obscureText: _obscurePassword,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                letterSpacing: 1,
              ),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Masukkan atau generate password',
                prefixIcon: const Icon(Icons.lock_rounded),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (ctrl.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: ctrl.text));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Password disalin'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ],
                ),
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Password wajib diisi' : null,
            ),
            const SizedBox(height: 8),
            StrengthIndicator(password: ctrl.text),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _showGeneratorSheet(key),
              icon: const Icon(Icons.auto_awesome_rounded, size: 17),
              label: const Text('Generate Password'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: const BorderSide(color: AppTheme.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 11,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ── Kode keamanan ─────────────────────────────────────────────────
    if (key == 'kode_keamanan') {
      return _fieldWrapper(
        label: label,
        child: TextFormField(
          controller: ctrl,
          obscureText: _obscureKodeKeamanan,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          style: const TextStyle(color: AppTheme.textPrimary, letterSpacing: 4),
          decoration: InputDecoration(
            hintText: '••••••',
            prefixIcon: const Icon(Icons.pin_rounded),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureKodeKeamanan
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscureKodeKeamanan = !_obscureKodeKeamanan),
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Kode keamanan wajib diisi';
            if (v.length != 6) return 'Harus 6 digit';
            return null;
          },
        ),
      );
    }

    // ── Nomor rekening ────────────────────────────────────────────────
    if (key == 'nomor_rekening') {
      return _fieldWrapper(
        label: label,
        child: TextFormField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(color: AppTheme.textPrimary, letterSpacing: 2),
          decoration: const InputDecoration(
            hintText: 'Nomor rekening atau kartu',
            prefixIcon: Icon(Icons.credit_card_rounded),
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? '$label wajib diisi' : null,
        ),
      );
    }

    // ── Kode pos ──────────────────────────────────────────────────────
    if (key == 'kode_pos') {
      return _fieldWrapper(
        label: label,
        child: TextFormField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(5),
          ],
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            hintText: '5 digit kode pos',
            prefixIcon: Icon(Icons.local_post_office_rounded),
          ),
        ),
      );
    }

    // ── Jenis kelamin ─────────────────────────────────────────────────
    if (key == 'jenis_kelamin') {
      final initial = ctrl.text.isEmpty ? null : ctrl.text;
      return _fieldWrapper(
        label: label,
        child: DropdownButtonFormField<String>(
          initialValue: initial,
          dropdownColor: AppTheme.surfaceHigh,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(prefixIcon: Icon(Icons.wc_rounded)),
          hint: const Text(
            'Pilih jenis kelamin',
            style: TextStyle(color: AppTheme.textHint),
          ),
          items: const [
            DropdownMenuItem(
              value: 'Laki-laki',
              child: Text(
                'Laki-laki',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
            ),
            DropdownMenuItem(
              value: 'Perempuan',
              child: Text(
                'Perempuan',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
            ),
          ],
          onChanged: (v) => setState(() => ctrl.text = v ?? ''),
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Pilih jenis kelamin' : null,
        ),
      );
    }

    // ── Golongan darah ────────────────────────────────────────────────
    if (key == 'golongan_darah') {
      final initial = ctrl.text.isEmpty ? null : ctrl.text;
      return _fieldWrapper(
        label: label,
        child: DropdownButtonFormField<String>(
          initialValue: initial,
          dropdownColor: AppTheme.surfaceHigh,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.bloodtype_rounded),
          ),
          hint: const Text(
            'Pilih golongan darah',
            style: TextStyle(color: AppTheme.textHint),
          ),
          items:
              [
                    'A',
                    'B',
                    'AB',
                    'O',
                    'A+',
                    'A-',
                    'B+',
                    'B-',
                    'AB+',
                    'AB-',
                    'O+',
                    'O-',
                  ]
                  .map(
                    (g) => DropdownMenuItem(
                      value: g,
                      child: Text(
                        g,
                        style: const TextStyle(color: AppTheme.textPrimary),
                      ),
                    ),
                  )
                  .toList(),
          onChanged: (v) => setState(() => ctrl.text = v ?? ''),
        ),
      );
    }

    // ── Status perkawinan ─────────────────────────────────────────────
    if (key == 'status_perkawinan') {
      final initial = ctrl.text.isEmpty ? null : ctrl.text;
      return _fieldWrapper(
        label: label,
        child: DropdownButtonFormField<String>(
          initialValue: initial,
          dropdownColor: AppTheme.surfaceHigh,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.favorite_rounded),
          ),
          hint: const Text(
            'Pilih status',
            style: TextStyle(color: AppTheme.textHint),
          ),
          items: ['Belum Kawin', 'Kawin', 'Cerai Hidup', 'Cerai Mati']
              .map(
                (s) => DropdownMenuItem(
                  value: s,
                  child: Text(
                    s,
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => ctrl.text = v ?? ''),
        ),
      );
    }

    // ── Alamat ────────────────────────────────────────────────────────
    if (key == 'alamat') {
      return _fieldWrapper(
        label: label,
        child: TextFormField(
          controller: ctrl,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
            height: 1.5,
          ),
          maxLines: 3,
          minLines: 2,
          keyboardType: TextInputType.streetAddress,
          decoration: const InputDecoration(
            hintText: 'Jl. ...',
            prefixIcon: Padding(
              padding: EdgeInsets.only(bottom: 32),
              child: Icon(Icons.location_on_rounded),
            ),
            alignLabelWithHint: true,
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? '$label wajib diisi' : null,
        ),
      );
    }

    // ── Default text field ────────────────────────────────────────────
    return _fieldWrapper(
      label: label,
      child: TextFormField(
        controller: ctrl,
        style: const TextStyle(color: AppTheme.textPrimary),
        keyboardType: _keyboardTypeFor(key),
        textCapitalization: _capitalizationFor(key),
        decoration: InputDecoration(
          hintText: label,
          prefixIcon: Icon(_iconFor(key)),
        ),
        validator: _isRequired(key)
            ? (v) =>
                  (v == null || v.trim().isEmpty) ? '$label wajib diisi' : null
            : null,
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _fieldWrapper({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 8),
        child,
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      color: AppTheme.textSecondary,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
    ),
  );

  TextInputType _keyboardTypeFor(String key) {
    if (key.contains('nomor') || key.contains('kode')) {
      return TextInputType.number;
    }
    if (key == 'username') return TextInputType.emailAddress;
    return TextInputType.text;
  }

  TextCapitalization _capitalizationFor(String key) {
    const wordsKeys = {
      'nama_lengkap',
      'pekerjaan',
      'agama',
      'kewarganegaraan',
      'tempat_lahir',
      'merk',
    };
    return wordsKeys.contains(key)
        ? TextCapitalization.words
        : TextCapitalization.none;
  }

  IconData _iconFor(String key) {
    switch (key) {
      case 'username':
        return Icons.person_rounded;
      case 'nama_lengkap':
        return Icons.badge_rounded;
      case 'nomor':
        return Icons.numbers_rounded;
      case 'tempat_lahir':
        return Icons.location_city_rounded;
      case 'tanggal_lahir':
        return Icons.cake_rounded;
      case 'agama':
        return Icons.church_rounded;
      case 'pekerjaan':
        return Icons.work_rounded;
      case 'kewarganegaraan':
        return Icons.flag_rounded;
      case 'merk':
        return Icons.business_rounded;
      default:
        return Icons.edit_rounded;
    }
  }

  bool _isRequired(String key) {
    const optional = {
      'kode_pos',
      'golongan_darah',
      'agama',
      'status_perkawinan',
      'pekerjaan',
      'kewarganegaraan',
    };
    return !optional.contains(key);
  }
}
