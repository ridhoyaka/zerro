import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/db_helper.dart';
import '../models/vault_entry.dart';
import '../utils/app_theme.dart';
import '../utils/field_definitions.dart';
import '../utils/password_generator.dart';
import 'add_edit_screen.dart';

class DetailScreen extends StatefulWidget {
  final VaultEntry entry;

  const DetailScreen({super.key, required this.entry});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final DBHelper _db = DBHelper();

  // Track which fields are revealed (for sensitive fields)
  final Set<String> _revealed = {};

  void _copy(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label disalin')));
  }

  Future<void> _navigateToEdit() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditScreen(
          category: widget.entry.category,
          existing: widget.entry,
        ),
      ),
    );
    if (result == true && mounted) Navigator.pop(context, true);
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Hapus Item',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          'Yakin ingin menghapus "${widget.entry.title}"?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.entry.id != null) {
      await _db.delete(widget.entry.id!);
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final color = AppTheme.categoryColor(entry.category);
    final icon = AppTheme.categoryIcon(entry.category);
    final fieldDefs = fieldsFor(entry.category);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(entry.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Edit',
            onPressed: _navigateToEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_rounded, color: AppTheme.danger),
            tooltip: 'Hapus',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Header ────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: color.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        entry.category.label,
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Field cards ───────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: const Border.fromBorderSide(
                BorderSide(color: AppTheme.border, width: 1),
              ),
            ),
            child: Column(
              children: [
                ...fieldDefs.entries.toList().asMap().entries.map((e) {
                  final idx = e.key;
                  final fieldKey = e.value.key;
                  final fieldLabel = e.value.value;
                  final value = entry.fields[fieldKey] ?? '';
                  final isLast = idx == fieldDefs.length - 1;

                  return Column(
                    children: [
                      _buildFieldRow(fieldKey, fieldLabel, value),
                      if (!isLast)
                        const Divider(height: 1, indent: 16, endIndent: 16),
                    ],
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Timestamps ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(14),
              border: const Border.fromBorderSide(
                BorderSide(color: AppTheme.border, width: 1),
              ),
            ),
            child: Column(
              children: [
                _tsRow(
                  Icons.add_circle_outline_rounded,
                  'Dibuat',
                  _fmt(entry.createdAt),
                ),
                const Divider(height: 16),
                _tsRow(
                  Icons.update_rounded,
                  'Diperbarui',
                  _fmt(entry.updatedAt),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldRow(String key, String label, String value) {
    final isSensitive = _isSensitiveField(key);
    final isRevealed = _revealed.contains(key);
    final displayValue = (isSensitive && !isRevealed)
        ? '•' * value.length.clamp(6, 20)
        : (value.isEmpty ? '—' : value);

    // Strength indicator for password
    final showStrength = key == 'password' && value.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textHint,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  displayValue,
                  style: TextStyle(
                    color: value.isEmpty
                        ? AppTheme.textHint
                        : AppTheme.textPrimary,
                    fontSize: (isSensitive && !isRevealed && value.isNotEmpty)
                        ? 20
                        : 14,
                    letterSpacing:
                        (isSensitive && !isRevealed && value.isNotEmpty)
                        ? 3
                        : 0,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ),
              if (value.isNotEmpty) ...[
                if (isSensitive)
                  IconButton(
                    icon: Icon(
                      isRevealed
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      size: 18,
                      color: AppTheme.textSecondary,
                    ),
                    onPressed: () => setState(() {
                      if (isRevealed) {
                        _revealed.remove(key);
                      } else {
                        _revealed.add(key);
                      }
                    }),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                if (isSensitive) const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(
                    Icons.copy_rounded,
                    size: 18,
                    color: AppTheme.textSecondary,
                  ),
                  onPressed: () => _copy(value, label),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
          if (showStrength) ...[
            const SizedBox(height: 8),
            _buildStrengthRow(value),
          ],
        ],
      ),
    );
  }

  Widget _buildStrengthRow(String password) {
    final strength = PasswordGenerator.strength(password);
    final label = PasswordGenerator.strengthLabel(strength);
    final color = _strengthColor(strength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ...List.generate(
              4,
              (i) => Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: i < strength ? color : AppTheme.surfaceHigh,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _tsRow(IconData icon, String label, String value) => Row(
    children: [
      Icon(icon, size: 15, color: AppTheme.textHint),
      const SizedBox(width: 8),
      Text(
        label,
        style: const TextStyle(color: AppTheme.textHint, fontSize: 12),
      ),
      const Spacer(),
      Text(
        value,
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
      ),
    ],
  );

  String _fmt(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/'
      '${dt.month.toString().padLeft(2, '0')}/'
      '${dt.year}  '
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}';

  bool _isSensitiveField(String key) =>
      key == 'password' ||
      key == 'kode_keamanan' ||
      key == 'nomor_rekening' ||
      key == 'nomor';

  Color _strengthColor(int s) {
    if (s <= 1) return AppTheme.danger;
    if (s == 2) return AppTheme.warning;
    return AppTheme.accentGreen;
  }
}
