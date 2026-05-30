import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/Components/SnackBar/SnackBarComp.dart';
import 'package:voxtrade_core/Components/common/Buttons/Button.dart';
import 'package:voxtrade_core/assembler/Controller/Instrument_Controller.dart';
import 'package:voxtrade_core/assembler/Controller/MarketController.dart';
import 'package:voxtrade_core/assembler/Controller/ThemeController.dart';
import 'package:voxtrade_core/assembler/Controller/Voice_Command_Settings_Controller.dart';
import 'package:voxtrade_core/assembler/Services/Voice_Nlp_Service.dart';
import 'package:voxtrade_core/assembler/Services/market_socket_service.dart';
import 'package:voxtrade_core/assembler/Services/voice_recorder.dart';
import 'package:voxtrade_core/assembler/Services/voice_silence_monitor.dart';
import 'package:voxtrade_core/assembler/common/enum.dart';
import 'package:voxtrade_core/pages/DashBoard_page.dart';
import 'package:voxtrade_core/pages/Home_page.dart';
import 'package:voxtrade_core/pages/Market_Buy_Sell.dart';
import 'package:voxtrade_core/pages/Wallet.dart';
import 'package:voxtrade_core/pages/Portfolio_Page.dart';
import 'package:voxtrade_core/pages/User_Info_Page.dart';
import 'package:voxtrade_core/pages/Voice_Command_Models_Page.dart';

import '../../assembler/Controller/NavBarController.dart';
import '../../pages/Markets.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell>
    with SingleTickerProviderStateMixin {
  final VoiceRecorder _recorder = VoiceRecorder();
  final VoiceNlpService _voiceNlpService = VoiceNlpService();
  final InstrumentController _instrumentController =
      Get.find<InstrumentController>();
  final MarketController _marketController = Get.find<MarketController>();
  final VoiceCommandSettingsController _voiceSettings =
      Get.find<VoiceCommandSettingsController>();
  final VoiceSilenceMonitor _silenceMonitor = VoiceSilenceMonitor();
  int? _voiceSilenceCountdown;
  bool _isVoiceListening = false;
  bool _isVoiceProcessing = false;
  bool _isExecutingVoiceOrder = false;
  bool _voiceCommandAborted = false;
  late final AnimationController _edgeGlowController;

  @override
  void initState() {
    super.initState();
    _edgeGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _silenceMonitor.stop();
    _edgeGlowController.dispose();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _onCenterMicTap() async {
    if (_isVoiceProcessing) {
      return;
    }
    if (_isVoiceListening) {
      await _stopAndProcessVoice();
      return;
    }
    await _startVoiceListening();
  }

  Future<void> _startVoiceListening() async {
    try {
      _voiceCommandAborted = false;
      await _recorder.start();
      if (!mounted) {
        return;
      }
      setState(() {
        _isVoiceListening = true;
        _voiceSilenceCountdown = null;
      });
      _edgeGlowController.repeat(reverse: true);
      _startSilenceMonitoring();
    } catch (e) {
      if (!mounted) {
        return;
      }
      SnackBarComp.show(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _startSilenceMonitoring() {
    _silenceMonitor.stop();
    final levelStream = _recorder.audioLevelStream;
    if (levelStream == null) {
      return;
    }

    _silenceMonitor.onCountdownTick = (secondsLeft) {
      if (!mounted) {
        return;
      }
      setState(() {
        _voiceSilenceCountdown = secondsLeft;
      });
    };
    _silenceMonitor.onCountdownCancelled = () {
      if (!mounted) {
        return;
      }
      setState(() {
        _voiceSilenceCountdown = null;
      });
    };
    _silenceMonitor.onComplete = () {
      if (!mounted || !_isVoiceListening) {
        return;
      }
      _stopAndProcessVoice();
    };

    _silenceMonitor.start(levelStream);
  }

  Future<void> _stopAndProcessVoice() async {
    _silenceMonitor.stop();
    _edgeGlowController.stop();
    setState(() {
      _isVoiceListening = false;
      _isVoiceProcessing = true;
      _voiceSilenceCountdown = null;
    });
    try {
      final audio = await _recorder.stop();
      final response = await _voiceNlpService.processVoiceCommand(
        audio: audio,
        sttModel: _voiceSettings.selectedModelId.value,
      );
      if (!mounted) {
        return;
      }
      if (_voiceCommandAborted) {
        return;
      }
      setState(() {
        _isVoiceProcessing = false;
      });
      await _showOrderConfirmationDialog(response);
    } catch (e) {
      if (mounted) {
        SnackBarComp.show(e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVoiceProcessing = false;
        });
      }
    }
  }

  Future<void> _showOrderConfirmationDialog(
    Map<String, dynamic> response,
  ) async {
    final confidence = _parseDouble(response['confidence']);
    if (confidence != null && confidence < 0.4) {
      SnackBarComp.show(
        'Voice command was not recognized clearly. Please try again.',
        title: 'Low confidence',
        status: SnackBarCompStatus.warning,
      );
      return;
    }

    final instrumentId = _resolveVoiceInstrumentId(
      response['asset']?.toString(),
    );
    final instrument =
        instrumentId == null
            ? null
            : _instrumentController.instruments.firstWhereOrNull(
              (i) => i.id == instrumentId,
            );
    final livePrice =
        instrument == null ? null : await _fetchLivePrice(instrument.symbol);
    final livePriceText =
        livePrice == null
            ? '-'
            : '${livePrice.toStringAsFixed(4)} ${_extractQuoteSymbol(instrument!.symbol)}';

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Voice Order'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _orderLine(
                    'Transcript',
                    (response['transcript'] ??
                            response['text'] ??
                            response['raw_text'] ??
                            '-')
                        .toString(),
                  ),
                  _orderLine('Intent', response['intent']?.toString() ?? '-'),
                  _orderLine(
                    'Order Type',
                    response['order_type']?.toString() ?? '-',
                  ),
                  _orderLine('Asset', response['asset']?.toString() ?? '-'),
                  _orderLine(
                    'Quantity',
                    response['quantity']?.toString() ?? '-',
                  ),
                  _orderLine('Live Price', livePriceText),
                  _orderLine('Price', response['price']?.toString() ?? '-'),
                  _orderLine(
                    'Confidence',
                    response['confidence']?.toString() ?? '-',
                  ),
                ],
              ),
            ),
            actionsAlignment: MainAxisAlignment.end,
            actions: [
              Button(
                purpose: ButtonPurpose.secondary,
                isLoading: false,
                label: 'Cancel',
                buttonWidth: 18,
                buttonHeight: 8,
                onPress: () async {
                  Navigator.of(context).pop(false);
                },
              ),
              Button(
                purpose: ButtonPurpose.primary,
                isLoading: _isExecutingVoiceOrder,
                label: 'Confirm',
                buttonWidth: 18,
                buttonHeight: 8,
                onPress: () async {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          ),
    );

    if (!mounted) {
      return;
    }

    if (confirmed == true) {
      await _executeVoiceOrder(response);
    } else {
      SnackBarComp.show('Order canceled.');
    }
  }

  Future<void> _abortVoiceCommand() async {
    _silenceMonitor.stop();
    _voiceCommandAborted = true;
    _edgeGlowController.stop();

    if (_isVoiceListening) {
      try {
        await _recorder.stop();
      } catch (_) {}
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _isVoiceListening = false;
      _isVoiceProcessing = false;
      _voiceSilenceCountdown = null;
    });
    SnackBarComp.show('Voice command canceled.');
  }

  Future<void> _executeVoiceOrder(Map<String, dynamic> response) async {
    if (_isExecutingVoiceOrder) {
      return;
    }

    final instrumentId = _resolveVoiceInstrumentId(
      response['asset']?.toString(),
    );
    if (instrumentId == null) {
      SnackBarComp.show(
        'Could not resolve instrument from voice asset.',
        title: 'Voice Order Error',
        status: SnackBarCompStatus.warning,
      );
      return;
    }

    final quantity = _parseDouble(response['quantity']);
    if (quantity == null || quantity <= 0) {
      SnackBarComp.show(
        'Voice quantity is missing or invalid.',
        title: 'Voice Order Error',
        status: SnackBarCompStatus.warning,
      );
      return;
    }

    final side = _normalizeSide(response['intent']?.toString());
    final orderType = _normalizeOrderType(response['order_type']?.toString());
    final limitPrice =
        orderType == 'limit' ? _parseDouble(response['price']) : null;

    if (orderType == 'limit' && (limitPrice == null || limitPrice <= 0)) {
      SnackBarComp.show(
        'Limit order needs a valid price.',
        title: 'Voice Order Error',
        status: SnackBarCompStatus.warning,
      );
      return;
    }

    setState(() {
      _isExecutingVoiceOrder = true;
    });

    try {
      await _marketController.callPlaceOrder(
        instrumentId,
        side,
        orderType,
        quantity,
        limitPrice,
        null,
        'voice',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isExecutingVoiceOrder = false;
        });
      }
    }
  }

  int? _resolveVoiceInstrumentId(String? assetRaw) {
    final asset = (assetRaw ?? '').trim().toUpperCase();
    if (asset.isEmpty) {
      return null;
    }

    final instruments = _instrumentController.instruments;
    if (instruments.isEmpty) {
      return null;
    }

    for (final instrument in instruments) {
      final symbol = instrument.symbol.toUpperCase();
      final shortName = instrument.shortName.toUpperCase();
      final name = instrument.name.toUpperCase();
      if (symbol == asset || shortName == asset || name == asset) {
        return instrument.id;
      }
    }

    for (final instrument in instruments) {
      final symbol = instrument.symbol.toUpperCase();
      final shortName = instrument.shortName.toUpperCase();
      final name = instrument.name.toUpperCase();
      if (symbol.contains(asset) ||
          shortName.contains(asset) ||
          name.contains(asset)) {
        return instrument.id;
      }
    }

    return null;
  }

  String _normalizeSide(String? intentRaw) {
    final intent = (intentRaw ?? '').toLowerCase();
    if (intent.contains('sell')) {
      return 'sell';
    }
    return 'buy';
  }

  String _normalizeOrderType(String? orderTypeRaw) {
    final orderType = (orderTypeRaw ?? '').toLowerCase();
    if (orderType.contains('limit')) {
      return 'limit';
    }
    return 'market';
  }

  double? _parseDouble(Object? value) {
    if (value == null) {
      return null;
    }
    final sanitized = value.toString().replaceAll(',', '').trim();
    return double.tryParse(sanitized);
  }

  Future<double?> _fetchLivePrice(String symbol) async {
    final socket = Get.find<MarketSocketService>();
    final normalizedSymbol = symbol.trim().toUpperCase();
    try {
      final tick = await socket
          .subscribeToSymbol(normalizedSymbol)
          .first
          .timeout(const Duration(seconds: 2));
      await socket.unsubscribeSymbol(normalizedSymbol);
      return tick.price;
    } catch (_) {
      await socket.unsubscribeSymbol(normalizedSymbol);
      return null;
    }
  }

  String _extractQuoteSymbol(String symbol) {
    final normalized = symbol.contains(':') ? symbol.split(':').last : symbol;
    if (normalized.contains('_')) {
      return normalized.split('_').last.toUpperCase();
    }
    if (normalized.endsWith('USDT')) return 'USDT';
    if (normalized.endsWith('USD')) return 'USD';
    return '';
  }

  Widget _orderLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final conroller = Get.put(NavBarController());
    final themeController = Get.find<ThemeController>();
    final drawerRoutes = <_DrawerRouteItem>[
      _DrawerRouteItem(
        title: 'User Info',
        subtitle: 'Profile and account details',
        icon: Icons.person_rounded,
        pageBuilder: () => const UserInfoPage(),
      ),
      _DrawerRouteItem(
        title: 'News',
        subtitle: 'Latest market and trading news',
        icon: Icons.newspaper_rounded,
        pageBuilder: () => HomePage(),
      ),
      // _DrawerRouteItem(
      //   title: 'Markets',
      //   subtitle: 'View live market moves',
      //   icon: Icons.auto_graph_rounded,
      //   pageBuilder: () => Markets(),
      // ),
      _DrawerRouteItem(
        title: 'Voice Models',
        subtitle: 'Manage speech-to-text models',
        icon: Icons.record_voice_over_rounded,
        pageBuilder: () => const VoiceCommandModelsPage(),
      ),
      _DrawerRouteItem(
        title: 'Trade',
        subtitle: 'Advanced ticket with market selector',
        icon: Icons.candlestick_chart_rounded,
        onTap: () async {
          final instrumentController = Get.find<InstrumentController>();
          if (instrumentController.instruments.isEmpty) {
            await instrumentController.fetchInstruments();
          }

          if (instrumentController.instruments.isEmpty) {
            SnackBarComp.show('No markets available right now');
            return;
          }

          final defaultId =
              instrumentController.resolveDefaultTradeInstrumentId();
          Get.to(
            () => MarketBuySell(instrumentId: defaultId),
            preventDuplicates: false,
            transition: Transition.rightToLeft,
          );
        },
      ),
      // _DrawerRouteItem(
      //   title: 'Wallet',
      //   subtitle: 'Manage your balance',
      //   icon: Icons.account_balance_wallet_rounded,
      //   pageBuilder: () => WalletPage(),
      // ),
      // _DrawerRouteItem(
      //   title: 'More pages soon',
      //   subtitle: 'You can plug new ideas here',
      //   icon: Icons.lightbulb_outline_rounded,
      //   onTap: () => SnackBarComp.show('Add your next page in drawerRoutes'),
      // ),
    ];

    return GetBuilder<NavBarController>(
      builder: (_) {
        return Obx(() {
          final isDarkMode = themeController.isDarkMode.value;
          final scheme = Theme.of(context).colorScheme;
          return Stack(
            children: [
              Scaffold(
                appBar: AppBar(
                  title: const Text('VoxTrade'),
                  centerTitle: true,
                  actions: [
                    IconButton(
                      onPressed: () {
                        themeController.changeTheme(
                          !themeController.isDarkMode.value,
                        );
                      },
                      icon: Icon(
                        themeController.isDarkMode.value
                            ? Icons.light_mode
                            : Icons.dark_mode,
                      ),
                    ),
                  ],
                ),
                drawer: Drawer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors:
                            isDarkMode
                                ? const [Color(0xFF071526), Color(0xFF10243A)]
                                : const [Color(0xFFF6FAFF), Color(0xFFEAF2FF)],
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                            decoration: BoxDecoration(
                              color:
                                  isDarkMode
                                      ? Colors.white.withValues(alpha: 0.05)
                                      : Colors.white.withValues(alpha: 0.85),
                              border: Border(
                                bottom: BorderSide(
                                  color: primaryColor.withValues(alpha: 0.18),
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    Icons.dashboard_customize_rounded,
                                    color: primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Navigation',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color:
                                              isDarkMode
                                                  ? Colors.white
                                                  : scheme.onSurface,
                                        ),
                                      ),
                                      Text(
                                        'Your pages at ease',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              isDarkMode
                                                  ? Colors.white70
                                                  : scheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(
                                12,
                                14,
                                12,
                                14,
                              ),
                              itemCount: drawerRoutes.length,
                              separatorBuilder:
                                  (_, __) => const SizedBox(height: 8),
                              itemBuilder: (_, index) {
                                final item = drawerRoutes[index];
                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () {
                                      Get.back();
                                      if (item.onTap != null) {
                                        item.onTap!.call();
                                        return;
                                      }
                                      if (item.pageBuilder != null) {
                                        Get.to(item.pageBuilder!);
                                      }
                                    },
                                    child: Ink(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        color:
                                            isDarkMode
                                                ? Colors.white.withValues(
                                                  alpha: 0.08,
                                                )
                                                : Colors.white.withValues(
                                                  alpha: 0.88,
                                                ),
                                        border: Border.all(
                                          color: primaryColor.withValues(
                                            alpha: 0.14,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: primaryColor.withValues(
                                                alpha: 0.14,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Icon(
                                              item.icon,
                                              color: primaryColor,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.title,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w700,
                                                    color:
                                                        isDarkMode
                                                            ? Colors.white
                                                            : scheme.onSurface,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  item.subtitle,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        isDarkMode
                                                            ? Colors.white70
                                                            : scheme
                                                                .onSurfaceVariant,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            size: 15,
                                            color:
                                                isDarkMode
                                                    ? Colors.white70
                                                    : scheme.onSurfaceVariant,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                body: IndexedStack(
                  index: conroller.tabIndex,
                  children: [
                    PortfolioPage(),
                    Markets(),
                    const SizedBox(),
                    const DashBoardPage(),
                    WalletPage(),
                  ],
                ),
                bottomNavigationBar: _BottomTradeNav(
                  currentIndex: conroller.tabIndex,
                  isDarkMode: isDarkMode,
                  onTabTap: conroller.changeTabIndex,
                  onCenterTap: _onCenterMicTap,
                ),
              ),
              if (_isVoiceListening || _isVoiceProcessing)
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _abortVoiceCommand,
                    child: AnimatedBuilder(
                      animation: _edgeGlowController,
                      builder: (context, _) {
                        final scheme = Theme.of(context).colorScheme;
                        final isDark =
                            Theme.of(context).brightness == Brightness.dark;
                        final t =
                            _isVoiceListening ? _edgeGlowController.value : 0.5;
                        final edgeColorA =
                            Color.lerp(
                              const Color(0xFF4F7CFF),
                              const Color(0xFF00D2FF),
                              t,
                            )!;
                        final edgeColorB =
                            Color.lerp(
                              const Color(0xFFB64DFF),
                              const Color(0xFF4F7CFF),
                              t,
                            )!;
                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 3,
                              color: edgeColorA.withValues(alpha: 0.95),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                edgeColorA.withValues(alpha: 0.18),
                                edgeColorB.withValues(alpha: 0.18),
                              ],
                            ),
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 2.3, sigmaY: 2.3),
                            child: Container(
                              color:
                                  isDark
                                      ? Colors.black.withValues(alpha: 0.10)
                                      : Colors.white.withValues(alpha: 0.08),
                              child: SafeArea(
                                child: Center(
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 22,
                                      vertical: 16,
                                    ),
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 380,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 22,
                                          vertical: 18,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              isDark
                                                  ? Colors.black.withValues(
                                                    alpha: 0.24,
                                                  )
                                                  : scheme.surface.withValues(
                                                    alpha: 0.78,
                                                  ),
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          border: Border.all(
                                            color:
                                                isDark
                                                    ? Colors.white.withValues(
                                                      alpha: 0.18,
                                                    )
                                                    : scheme.primary.withValues(
                                                      alpha: 0.20,
                                                    ),
                                          ),
                                        ),
                                        child: Material(
                                          type: MaterialType.transparency,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                _isVoiceListening
                                                    ? (_voiceSilenceCountdown !=
                                                            null
                                                        ? Icons.timer_rounded
                                                        : Icons
                                                            .graphic_eq_rounded)
                                                    : Icons
                                                        .hourglass_top_rounded,
                                                color:
                                                    isDark
                                                        ? Colors.white
                                                            .withValues(
                                                              alpha: 0.96,
                                                            )
                                                        : scheme.primary,
                                                size: 30,
                                              ),
                                              const SizedBox(height: 10),
                                              if (_isVoiceListening &&
                                                  _voiceSilenceCountdown !=
                                                      null) ...[
                                                Text(
                                                  '${_voiceSilenceCountdown!}',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color:
                                                        isDark
                                                            ? Colors.white
                                                            : scheme.onSurface,
                                                    fontSize: 48,
                                                    fontWeight: FontWeight.w800,
                                                    height: 1,
                                                    decoration:
                                                        TextDecoration.none,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                              ],
                                              Text(
                                                _isVoiceListening
                                                    ? (_voiceSilenceCountdown !=
                                                            null
                                                        ? 'Finishing in $_voiceSilenceCountdown...'
                                                        : 'Listening to your order')
                                                    : 'Analyzing your command',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color:
                                                      isDark
                                                          ? Colors.white
                                                          : scheme.onSurface,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 0.2,
                                                  decoration:
                                                      TextDecoration.none,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                _isVoiceListening
                                                    ? (_voiceSilenceCountdown !=
                                                            null
                                                        ? 'Keep speaking to continue listening, or wait to analyze.'
                                                        : 'Speak clearly. Tap anywhere to cancel.')
                                                    : 'Please wait... Tap anywhere to cancel.',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color:
                                                      isDark
                                                          ? Colors.white
                                                              .withValues(
                                                                alpha: 0.86,
                                                              )
                                                          : scheme
                                                              .onSurfaceVariant,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  height: 1.35,
                                                  decoration:
                                                      TextDecoration.none,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          );
        });
      },
    );
  }
}

class _DrawerRouteItem {
  const _DrawerRouteItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.pageBuilder,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget Function()? pageBuilder;
  final FutureOr<void> Function()? onTap;
}

class _BottomTradeNav extends StatelessWidget {
  const _BottomTradeNav({
    required this.currentIndex,
    required this.isDarkMode,
    required this.onTabTap,
    required this.onCenterTap,
  });

  final int currentIndex;
  final bool isDarkMode;
  final ValueChanged<int> onTabTap;
  final VoidCallback onCenterTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = isDarkMode ? const Color(0xFF061527) : Colors.white;
    final inactive =
        isDarkMode ? const Color(0xFF9AA5B5) : const Color(0xFF7C8797);
    final selected = primaryColor;
    final centerLabelColor = isDarkMode ? Colors.white : scheme.onSurface;
    final shadowColor =
        isDarkMode
            ? Colors.black.withValues(alpha: 0.22)
            : Colors.black.withValues(alpha: 0.08);

    return SafeArea(
      top: false,
      child: SizedBox(
        height: 84,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: bg,
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _NavItem(
                      icon: Icons.folder_rounded,
                      label: 'Portfolio',
                      isSelected: currentIndex == 0,
                      selectedColor: selected,
                      unselectedColor: inactive,
                      onTap: () => onTabTap(0),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.auto_graph_rounded,
                      label: 'Markets',
                      isSelected: currentIndex == 1,
                      selectedColor: selected,
                      unselectedColor: inactive,
                      onTap: () => onTabTap(1),
                    ),
                  ),
                  const SizedBox(width: 72),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.dashboard_customize_rounded,
                      label: 'Dashboard',
                      isSelected: currentIndex == 3,
                      selectedColor: selected,
                      unselectedColor: inactive,
                      onTap: () => onTabTap(3),
                    ),
                  ),

                  Expanded(
                    child: _NavItem(
                      icon: Icons.person_outline_rounded,
                      label: 'Assets',
                      isSelected: currentIndex == 4,
                      selectedColor: selected,
                      unselectedColor: inactive,
                      onTap: () => onTabTap(4),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: -2,
              child: GestureDetector(
                onTap: onCenterTap,
                behavior: HitTestBehavior.opaque,
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected,
                        boxShadow: [
                          BoxShadow(
                            color: selected.withValues(alpha: 0.55),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.mic,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Voice',
                      style: TextStyle(
                        color: centerLabelColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? selectedColor : unselectedColor;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 21, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
