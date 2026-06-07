import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/vault_entry.dart';
import '../utils/app_theme.dart';
import 'add_edit_screen.dart';
import 'detail_screen.dart';

class CategoryListScreen extends StatefulWidget {
  final VaultCategory category;

  const CategoryListScreen({super.key, required this.category});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  final DBHelper _db = DBHelper();
  List<VaultEntry> _entries = [];
  List<VaultEntry> _filtered = [];
  String _searchQuery = '';
  bool _isSearching = false;

  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final data = await _db.getByCategory(widget.category);
    if (!mounted) return;
    setState(() {
      _entries = data;
      _applyFilter();
    });
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filtered = List.from(_entries);
    } else {
      final q = _searchQuery.toLowerCase();
      _filtered = _entries
          .where(
            (e) =>
                e.title.toLowerCase().contains(q) ||
                e.subtitle.toLowerCase().contains(q),
          )
          .toList();
    }
  }

  void _onSearch(String val) {
    setState(() {
      _searchQuery = val;
      _applyFilter();
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchCtrl.clear();
        _searchQuery = '';
        _applyFilter();
      } else {
        Future.delayed(
          const Duration(milliseconds: 100),
          () => _searchFocus.requestFocus(),
        );
      }
    });
  }

  Future<void> _navigateToAdd() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditScreen(category: widget.category),
      ),
    );
    if (result == true) _load();
  }

  Future<void> _navigateToDetail(VaultEntry entry) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => DetailScreen(entry: entry)),
    );
    if (result == true) _load();
  }

  Future<void> _confirmDelete(VaultEntry entry) async {
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
          'Yakin ingin menghapus "${entry.title}"?',
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

    if (confirmed == true && entry.id != null) {
      await _db.delete(entry.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('"${entry.title}" dihapus')));
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.categoryColor(widget.category);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(widget.category.label),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _isSearching ? Icons.close_rounded : Icons.search_rounded,
                key: ValueKey(_isSearching),
                color: _isSearching ? AppTheme.primary : AppTheme.textSecondary,
                size: 22,
              ),
            ),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            child: _isSearching
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: TextField(
                      controller: _searchCtrl,
                      focusNode: _searchFocus,
                      onChanged: _onSearch,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Cari...',
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  _onSearch('');
                                },
                              )
                            : null,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // List
          Expanded(
            child: _filtered.isEmpty
                ? _buildEmpty()
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 4, bottom: 96),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) => _EntryTile(
                      entry: _filtered[i],
                      color: color,
                      icon: AppTheme.categoryIcon(widget.category),
                      onTap: () => _navigateToDetail(_filtered[i]),
                      onEdit: () async {
                        final result = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddEditScreen(
                              category: widget.category,
                              existing: _filtered[i],
                            ),
                          ),
                        );
                        if (result == true) _load();
                      },
                      onDelete: () => _confirmDelete(_filtered[i]),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAdd,
        backgroundColor: color,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded, size: 26),
      ),
    );
  }

  Widget _buildEmpty() {
    final isFiltered = _searchQuery.isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isFiltered
                  ? Icons.search_off_rounded
                  : AppTheme.categoryIcon(widget.category),
              size: 52,
              color: AppTheme.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              isFiltered
                  ? 'Tidak ada hasil'
                  : 'Belum ada ${widget.category.label}',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isFiltered
                  ? 'Coba kata kunci lain'
                  : 'Tap tombol + untuk menambahkan',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textHint,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Entry tile ────────────────────────────────────────────────────────────────

class _EntryTile extends StatelessWidget {
  final VaultEntry entry;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EntryTile({
    required this.entry,
    required this.color,
    required this.icon,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
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
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (entry.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        entry.subtitle,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: AppTheme.textHint,
                  size: 20,
                ),
                color: AppTheme.surfaceHigh,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (v) {
                  if (v == 'edit') onEdit();
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_rounded,
                          color: AppTheme.primary,
                          size: 18,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Edit',
                          style: TextStyle(color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_rounded,
                          color: AppTheme.danger,
                          size: 18,
                        ),
                        SizedBox(width: 10),
                        Text('Hapus', style: TextStyle(color: AppTheme.danger)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
