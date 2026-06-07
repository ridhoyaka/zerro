import '../models/vault_entry.dart';

/// Definisi field per kategori: fieldKey → label
Map<String, String> fieldsFor(VaultCategory cat) {
  switch (cat) {
    case VaultCategory.login:
      return {'username': 'Username / Email', 'password': 'Password'};
    case VaultCategory.kartu:
      return {
        'nama_lengkap': 'Nama Lengkap (sesuai kartu)',
        'nomor_rekening': 'Nomor Rekening / Kartu',
        'merk': 'Merk / Bank',
        'kode_keamanan': 'Kode Keamanan (6 digit)',
      };
    case VaultCategory.identitas:
      return {
        'nomor': 'Nomor Dokumen',
        'nama_lengkap': 'Nama Lengkap',
        'tempat_lahir': 'Tempat Lahir',
        'tanggal_lahir': 'Tanggal Lahir',
        'jenis_kelamin': 'Jenis Kelamin',
        'alamat': 'Alamat Lengkap',
        'kode_pos': 'Kode Pos',
        'golongan_darah': 'Golongan Darah',
        'agama': 'Agama',
        'status_perkawinan': 'Status Perkawinan',
        'pekerjaan': 'Pekerjaan',
        'kewarganegaraan': 'Kewarganegaraan',
      };
    case VaultCategory.catatanAman:
      return {'catatan': 'Catatan'};
  }
}
