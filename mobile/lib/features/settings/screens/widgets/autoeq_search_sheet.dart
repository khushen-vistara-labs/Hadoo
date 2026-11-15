import 'package:flutter/material.dart';
import 'package:flick/widgets/lokal/lokal_toast.dart';

import 'package:flick/core/constants/app_constants.dart';
import 'package:flick/core/theme/lokal_tokens.dart';
import 'package:flick/services/autoeq_catalog_service.dart';
import 'package:flick/l10n/l10n.dart';

/// Opens the AutoEQ headphone picker. Returns the chosen entry, or null if
/// dismissed. The caller applies the result to the equalizer.
Future<AutoEqEntry?> showAutoEqSearchSheet(BuildContext context) {
  final t = context.lokal;
  return showModalBottomSheet<AutoEqEntry>(
    useRootNavigator: true,
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    // A solid theme surface over a dimmed page, no blur.
    backgroundColor: t.surface,
    barrierColor: Colors.black.withValues(alpha: t.isLight ? .25 : .5),
    shape: RoundedRectangleBorder(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      side: BorderSide(color: t.border),
    ),
    builder: (context) => ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      child: const _AutoEqSearchSheet(),
    ),
  );
}

class _AutoEqSearchSheet extends StatefulWidget {
  const _AutoEqSearchSheet();

  @override
  State<_AutoEqSearchSheet> createState() => _AutoEqSearchSheetState();
}

class _AutoEqSearchSheetState extends State<_AutoEqSearchSheet> {
  final _service = AutoEqCatalogService.instance;
  final _queryController = TextEditingController();
  final _scrollController = ScrollController();

  List<AutoEqEntry> _all = const [];
  List<String> _brands = const [];
  List<AutoEqSearchResult> _results = const [];
  String? _brand;
  AutoEqEntry? _selected;
  bool _loading = true;
  bool _searchingOnline = false;

  @override
  void initState() {
    super.initState();
    _queryController.addListener(_onQueryChanged);
    _load();
  }

  @override
  void dispose() {
    _queryController.removeListener(_onQueryChanged);
    _queryController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final entries = await _service.loadBundled();
    final brands = await _service.loadBrands();
    if (!mounted) return;
    setState(() {
      _all = entries;
      _brands = brands;
      _loading = false;
      _recompute();
    });
  }

  void _onQueryChanged() {
    if (mounted) setState(_recompute);
  }

  void _recompute() {
    _results = _service.search(_queryController.text, brand: _brand, limit: 80);
  }

  void _select(AutoEqEntry entry) {
    setState(() => _selected = entry);
  }

  void _apply() {
    final entry = _selected;
    if (entry == null) return;
    Navigator.of(context).pop(entry);
  }

  Future<void> _searchOnline() async {
    final query = _queryController.text.trim();
    if (query.isEmpty) {
      _toast(l10n.typeABrandAndModelTo);
      return;
    }
    String brand = _brand ?? '';
    String model = query;
    if (brand.isEmpty) {
      final known = _brands.firstWhere(
        (b) => query.toLowerCase().startsWith(b.toLowerCase()),
        orElse: () => '',
      );
      if (known.isNotEmpty) {
        brand = known;
        model = query.substring(known.length).trim();
      }
    } else {
      model = query;
    }

    setState(() => _searchingOnline = true);
    try {
      final entry = await _service.fetchOnline(brand, model);
      if (!mounted) return;
      if (entry != null) {
        setState(() {
          _selected = entry;
          _results = [AutoEqSearchResult(entry, 999), ..._results];
        });
        _toast(l10n.foundOnline(entry.displayName));
      } else {
        _toast(l10n.notFoundOnlineTryADifferent);
      }
    } finally {
      if (mounted) setState(() => _searchingOnline = false);
    }
  }

  void _toast(String message) {
    if (!mounted) return;
    LokalToast.fromSnackBar(context, 
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(context),
        _buildSearchField(context),
        const SizedBox(height: AppConstants.spacingSm),
        SizedBox(
          height: 38,
          child: _brands.isEmpty
              ? const SizedBox.shrink()
              : ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingLg,
                  ),
                  children: [
                    _brandChip(context, null, l10n.all),
                    for (final b in _brands) _brandChip(context, b, b),
                  ],
                ),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        Expanded(child: _buildBody(context)),
        _buildFooter(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacingLg,
        AppConstants.spacingSm,
        AppConstants.spacingLg,
        AppConstants.spacingXs,
      ),
      child: Row(
        children: [
          Icon(Icons.headphones_rounded, color: context.lokal.text, size: 22),
          const SizedBox(width: AppConstants.spacingSm),
          Expanded(
            child: Text(
              l10n.autoeqHeadphones2,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.lokal.text,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(AppConstants.spacingXs),
              decoration: BoxDecoration(
                color: context.lokal.surface2,
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                border: Border.all(color: context.lokal.border),
              ),
              child: Icon(
                Icons.close_rounded,
                color: context.lokal.muted,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingLg,
        vertical: AppConstants.spacingXs,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: context.lokal.surface3,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(color: context.lokal.border),
        ),
        child: TextField(
          controller: _queryController,
          style: TextStyle(color: context.lokal.text),
          decoration: InputDecoration(
            hintText: _all.isEmpty
                ? l10n.searchHeadphones
                : l10n.searchModelCount(_all.length),
            hintStyle: TextStyle(color: context.lokal.muted2),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: context.lokal.muted,
              size: 20,
            ),
            suffixIcon: _queryController.text.isEmpty
                ? null
                : IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      color: context.lokal.muted,
                      size: 20,
                    ),
                    onPressed: () {
                      _queryController.clear();
                      _onQueryChanged();
                    },
                  ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingMd,
              vertical: AppConstants.spacingSm,
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _brandChip(BuildContext context, String? brand, String label) {
    final selected = _brand == brand;
    return Padding(
      padding: const EdgeInsets.only(right: AppConstants.spacingXs),
      child: GestureDetector(
        onTap: () => setState(() {
          _brand = selected ? null : brand;
          _recompute();
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingMd,
            vertical: AppConstants.spacingXs,
          ),
          decoration: BoxDecoration(
            color: selected
                ? context.lokal.accent.withValues(alpha: 0.18)
                : context.lokal.surface3,
            borderRadius: BorderRadius.circular(AppConstants.radiusRound),
            border: Border.all(
              color: selected ? context.lokal.accent : context.lokal.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? context.lokal.accent : context.lokal.muted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: context.lokal.text,
        ),
      );
    }
    if (_results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          child: Text(
            l10n.noMatchesTryFewerWordsOr,
            textAlign: TextAlign.center,
            style: TextStyle(color: context.lokal.muted),
          ),
        ),
      );
    }
    return Scrollbar(
      controller: _scrollController,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingLg,
          vertical: AppConstants.spacingXs,
        ),
        itemCount: _results.length,
        itemBuilder: (context, i) => _resultTile(context, _results[i].entry),
      ),
    );
  }

  Widget _resultTile(BuildContext context, AutoEqEntry entry) {
    final selected = _selected?.id == entry.id;
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingXs),
      decoration: BoxDecoration(
        color: selected
            ? context.lokal.accent.withValues(alpha: 0.12)
            : context.lokal.surface2,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(
          color: selected ? context.lokal.accent : context.lokal.border,
        ),
      ),
      child: ListTile(
        onTap: () => _select(entry),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMd,
          vertical: AppConstants.spacingXs,
        ),
        title: Text(
          entry.displayName,
          style: TextStyle(
            color: context.lokal.text,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          l10n.bandsPreampDb(
            entry.bands.length,
            entry.preampDb.toStringAsFixed(1),
            entry.source,
          ),
          style: TextStyle(color: context.lokal.muted2, fontSize: 12),
        ),
        trailing: Icon(
          selected ? Icons.check_circle_rounded : Icons.circle_outlined,
          color: selected ? context.lokal.accent : context.lokal.muted2,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final canApply = _selected != null;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacingLg,
        AppConstants.spacingSm,
        AppConstants.spacingLg,
        AppConstants.spacingMd,
      ),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.lokal.border, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_searchingOnline)
            Padding(
              padding: EdgeInsets.only(bottom: AppConstants.spacingXs),
              child: LinearProgressIndicator(
                minHeight: 2,
                color: context.lokal.accent,
                backgroundColor: context.lokal.border,
              ),
            ),
          Row(
            children: [
              TextButton.icon(
                onPressed: _searchingOnline ? null : _searchOnline,
                icon: const Icon(Icons.cloud_download_outlined, size: 18),
                label: Text(l10n.searchOnline2),
              ),
              const Spacer(),
              FilledButton(
                onPressed: canApply ? _apply : null,
                style: FilledButton.styleFrom(
                  backgroundColor: context.lokal.accent,
                  disabledBackgroundColor: context.lokal.surface2,
                  foregroundColor: context.lokal.onAccent,
                  disabledForegroundColor: context.lokal.muted2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  ),
                ),
                child: Text(
                  _selected == null
                      ? l10n.apply
                      : l10n.apply2(_selected!.model),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
