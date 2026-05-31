import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/Components/ModelDto/InstrumentDTO.dart';
import 'package:voxtrade_core/Components/Market/MarketViewrCard.dart';
import 'package:voxtrade_core/Components/PopUp/PopUpModal.dart';
import 'package:voxtrade_core/assembler/Controller/Instrument_Controller.dart';
import 'package:voxtrade_core/Components/shimer/page_loading_shimmers.dart';
import 'package:voxtrade_core/assembler/common/enum.dart';

class Markets extends StatefulWidget {
  const Markets({super.key});

  @override
  State<Markets> createState() => _MarketsState();
}

class _MarketsState extends State<Markets> {
  final TextEditingController _searchController = TextEditingController();
  static const List<String> _marketTabs = ['all', 'crypto', 'forex', 'stock'];
  String _selectedTab = _marketTabs.first;
  _MarketSessionFilter _sessionFilter = _MarketSessionFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final instrumentController = Get.find<InstrumentController>();
    final scheme = Theme.of(context).colorScheme;

    return Obx(() {
      final isLoading = instrumentController.isLoading.value;
      final instruments = instrumentController.instruments.toList(
        growable: false,
      );

      final filtered = _filterInstruments(
        instruments: instruments,
        selectedTab: _selectedTab,
        searchQuery: _searchController.text,
        sessionFilter: _sessionFilter,
      );

      return Scaffold(
        backgroundColor: scheme.surface,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search markets by name or symbol',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon:
                            _searchController.text.isEmpty
                                ? null
                                : IconButton(
                                  icon: const Icon(Icons.close_rounded),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    tooltip: 'Filters',
                    onPressed: _openFiltersModal,
                    icon: const Icon(Icons.filter_alt_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          _sessionFilter == _MarketSessionFilter.open
                              ? primaryColor
                              : Colors.transparent,
                      foregroundColor:
                          _sessionFilter == _MarketSessionFilter.open
                              ? Colors.white
                              : scheme.onSurfaceVariant,
                      side:
                          _sessionFilter == _MarketSessionFilter.open
                              ? BorderSide(
                                color: scheme.outlineVariant.withValues(
                                  alpha: 0.7,
                                ),
                              )
                              : BorderSide.none,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 42,
                child: Row(
                  children:
                      _marketTabs.map((tab) {
                        final selected = _selectedTab == tab;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTab = tab),
                            behavior: HitTestBehavior.opaque,
                            child: Column(
                              children: [
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      _tabLabel(tab),
                                      style: TextStyle(
                                        fontWeight:
                                            selected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                        color:
                                            selected
                                                ? scheme.primary
                                                : scheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  height: 2,
                                  width: selected ? 42 : 0,
                                  color: scheme.primary,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Session: ${_sessionLabel(_sessionFilter)}',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child:
                  isLoading && instruments.isEmpty
                      ? const MarketsListPageShimmer()
                      : filtered.isEmpty
                      ? Center(
                        child: Text(
                          'No markets match your filters',
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      )
                      : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const MarketListDivider(),
                        itemBuilder: (_, index) {
                          return MarketChartTile(
                            key: ValueKey(filtered[index].symbol),
                            instrument: filtered[index],
                            index: index,
                          );
                        },
                      ),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _openFiltersModal() async {
    var tempFilter = _sessionFilter;
    await showDialog<void>(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return PopUpModal(
              title: 'Market Filters',
              centerTitle: true,
              height: 160,
              content: Column(
                children: [
                  RadioListTile<_MarketSessionFilter>(
                    dense: true,
                    title: const Text('All sessions'),
                    value: _MarketSessionFilter.all,
                    groupValue: tempFilter,
                    onChanged:
                        (v) =>
                            setModalState(() => tempFilter = v ?? tempFilter),
                  ),
                  RadioListTile<_MarketSessionFilter>(
                    dense: true,
                    title: const Text('Open markets only'),
                    value: _MarketSessionFilter.open,
                    groupValue: tempFilter,
                    onChanged:
                        (v) =>
                            setModalState(() => tempFilter = v ?? tempFilter),
                  ),
                  RadioListTile<_MarketSessionFilter>(
                    dense: true,
                    title: const Text('Closed markets only'),
                    value: _MarketSessionFilter.closed,
                    groupValue: tempFilter,
                    onChanged:
                        (v) =>
                            setModalState(() => tempFilter = v ?? tempFilter),
                  ),
                ],
              ),
              onApply: () async {
                setState(() => _sessionFilter = tempFilter);
                Navigator.of(context).pop();
              },
            );
          },
        );
      },
    );
  }

  String _tabLabel(String value) {
    switch (value) {
      case 'all':
        return 'All';
      case 'crypto':
        return 'Crypto';
      case 'forex':
        return 'Forex';
      case 'stock':
        return 'Stock';
      default:
        return value;
    }
  }

  String _sessionLabel(_MarketSessionFilter value) {
    switch (value) {
      case _MarketSessionFilter.all:
        return 'All';
      case _MarketSessionFilter.open:
        return 'Open';
      case _MarketSessionFilter.closed:
        return 'Closed';
    }
  }

  String? _normalizeType(String raw) {
    final value = raw.trim().toLowerCase();
    if (value.isEmpty) return null;
    if (value.contains('crypto')) return 'crypto';
    if (value.contains('forex') || value.contains('fx')) return 'forex';
    if (value.contains('stock') || value.contains('equit')) return 'stock';
    return null;
  }

  List<InstrumentDTO> _filterInstruments({
    required List<InstrumentDTO> instruments,
    required String selectedTab,
    required String searchQuery,
    required _MarketSessionFilter sessionFilter,
  }) {
    final query = searchQuery.trim().toLowerCase();
    final nowUtc = DateTime.now().toUtc();

    return instruments.where((instrument) {
      final marketType = _marketTypeForInstrument(instrument);
      final tabMatches = selectedTab == 'all' || marketType == selectedTab;

      final textMatches =
          query.isEmpty ||
          instrument.symbol.toLowerCase().contains(query) ||
          instrument.name.toLowerCase().contains(query) ||
          instrument.shortName.toLowerCase().contains(query);

      final isOpen = _isMarketOpen(marketType, nowUtc);
      final statusMatches =
          sessionFilter == _MarketSessionFilter.all ||
          (sessionFilter == _MarketSessionFilter.open && isOpen) ||
          (sessionFilter == _MarketSessionFilter.closed && !isOpen);

      return tabMatches && textMatches && statusMatches;
    }).toList();
  }

  String _marketTypeForInstrument(InstrumentDTO instrument) {
    final typeFromApi = _normalizeType(instrument.instrumentType ?? '');
    if (typeFromApi != null) return typeFromApi;

    final raw =
        instrument.symbol.contains(':')
            ? instrument.symbol.split(':').last.toUpperCase()
            : instrument.symbol.toUpperCase();
    final exchange =
        instrument.symbol.contains(':')
            ? instrument.symbol.split(':').first.toUpperCase()
            : '';

    if (exchange == 'BINANCE' ||
        raw.contains('BTC') ||
        raw.contains('ETH') ||
        raw.endsWith('USDT')) {
      return 'crypto';
    }
    if (exchange == 'OANDA' || raw.contains('_') || raw.contains('/')) {
      return 'forex';
    }
    return 'stock';
  }

  bool _isMarketOpen(String marketType, DateTime nowUtc) {
    switch (marketType) {
      case 'crypto':
        return true;
      case 'forex':
        return _isForexMarketOpen(nowUtc);
      case 'stock':
      default:
        if (nowUtc.weekday == DateTime.saturday ||
            nowUtc.weekday == DateTime.sunday) {
          return false;
        }
        final minutes = (nowUtc.hour * 60) + nowUtc.minute;
        const openMinutes = (13 * 60) + 30;
        const closeMinutes = 20 * 60;
        return minutes >= openMinutes && minutes < closeMinutes;
    }
  }

  bool _isForexMarketOpen(DateTime utcInput) {
    final nowUtc = utcInput.isUtc ? utcInput : utcInput.toUtc();
    final isDst = _isNewYorkDst(nowUtc);
    final nyNow = nowUtc.subtract(Duration(hours: isDst ? 4 : 5));

    final day = nyNow.weekday;
    final timeMinutes = (nyNow.hour * 60) + nyNow.minute;
    const fivePm = 17 * 60;

    if (day == DateTime.sunday && timeMinutes < fivePm) return false;
    if (day == DateTime.friday && timeMinutes >= fivePm) return false;
    if (day == DateTime.saturday) return false;
    return true;
  }

  bool _isNewYorkDst(DateTime utc) {
    final year = utc.year;
    final dstStart = _nthSundayOfMonthUtc(year, 3, 2, 7);
    final dstEnd = _nthSundayOfMonthUtc(year, 11, 1, 6);
    return utc.isAfter(dstStart) && utc.isBefore(dstEnd);
  }

  DateTime _nthSundayOfMonthUtc(int year, int month, int nth, int hourUtc) {
    final firstDay = DateTime.utc(year, month, 1);
    final daysUntilSunday = DateTime.sunday - firstDay.weekday;
    final firstSunday = firstDay.add(
      Duration(
        days: daysUntilSunday < 0 ? daysUntilSunday + 7 : daysUntilSunday,
      ),
    );
    return firstSunday.add(Duration(days: (nth - 1) * 7, hours: hourUtc));
  }
}

enum _MarketSessionFilter { all, open, closed }
