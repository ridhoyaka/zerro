import 'dart:convert';

/// Kategori vault yang tersedia
enum VaultCategory { login, kartu, identitas, catatanAman }

extension VaultCategoryX on VaultCategory {
  String get label {
    switch (this) {
      case VaultCategory.login:
        return 'Login';
      case VaultCategory.kartu:
        return 'Kartu';
      case VaultCategory.identitas:
        return 'Identitas';
      case VaultCategory.catatanAman:
        return 'Catatan Aman';
    }
  }

  String get key {
    switch (this) {
      case VaultCategory.login:
        return 'login';
      case VaultCategory.kartu:
        return 'kartu';
      case VaultCategory.identitas:
        return 'identitas';
      case VaultCategory.catatanAman:
        return 'catatan_aman';
    }
  }

  static VaultCategory fromKey(String key) {
    switch (key) {
      case 'login':
        return VaultCategory.login;
      case 'kartu':
        return VaultCategory.kartu;
      case 'identitas':
        return VaultCategory.identitas;
      case 'catatan_aman':
        return VaultCategory.catatanAman;
      default:
        return VaultCategory.login;
    }
  }
}

/// Satu entri vault — field dinamis disimpan sebagai JSON di kolom `fields`
class VaultEntry {
  final int? id;
  final String title;
  final VaultCategory category;
  final Map<String, String> fields; // key → value
  final DateTime createdAt;
  final DateTime updatedAt;

  const VaultEntry({
    this.id,
    required this.title,
    required this.category,
    required this.fields,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VaultEntry.create({
    required String title,
    required VaultCategory category,
    required Map<String, String> fields,
  }) {
    final now = DateTime.now();
    return VaultEntry(
      title: title,
      category: category,
      fields: fields,
      createdAt: now,
      updatedAt: now,
    );
  }

  VaultEntry copyWith({
    int? id,
    String? title,
    VaultCategory? category,
    Map<String, String>? fields,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VaultEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      fields: fields ?? this.fields,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'title': title,
    'category': category.key,
    'fields': jsonEncode(fields),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory VaultEntry.fromMap(Map<String, dynamic> map) {
    Map<String, String> parsedFields = {};
    try {
      final decoded = jsonDecode(map['fields'] as String? ?? '{}');
      if (decoded is Map) {
        parsedFields = decoded.map(
          (k, v) => MapEntry(k.toString(), v.toString()),
        );
      }
    } catch (_) {}

    return VaultEntry(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      category: VaultCategoryX.fromKey(map['category'] as String? ?? 'login'),
      fields: parsedFields,
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(map['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  /// Nilai field pertama yang relevan untuk ditampilkan sebagai subtitle di list
  String get subtitle {
    switch (category) {
      case VaultCategory.login:
        return fields['username'] ?? '';
      case VaultCategory.kartu:
        return fields['nomor_rekening'] ?? '';
      case VaultCategory.identitas:
        return fields['nama_lengkap'] ?? '';
      case VaultCategory.catatanAman:
        return fields['catatan'] ?? '';
    }
  }
}
