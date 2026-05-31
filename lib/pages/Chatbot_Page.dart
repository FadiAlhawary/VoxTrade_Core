import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/Components/SnackBar/SnackBarComp.dart';
import 'package:voxtrade_core/assembler/Controller/Chatbot_Controller.dart';
import 'package:voxtrade_core/assembler/Controller/ThemeController.dart';
import 'package:voxtrade_core/assembler/Models/chat_message.dart';
import 'package:voxtrade_core/assembler/common/enum.dart';

class ChatbotPage extends StatelessWidget {
  const ChatbotPage({super.key});

  @override
  Widget build(BuildContext context) {
    final chat = Get.find<ChatbotController>();
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      final palette = _ChatPalette(
        isDark: themeController.isDarkMode.value,
        scheme: Theme.of(context).colorScheme,
      );

      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: _ChatAppBar(
          botName: chat.botName,
          palette: palette,
          onClear: () => _confirmClear(context, chat),
        ),
        body: Stack(
          children: [
            _AmbientBackground(palette: palette),
            Column(
              children: [
                SizedBox(
                  height:
                      MediaQuery.paddingOf(context).top + kToolbarHeight + 8,
                ),
                Expanded(
                  child: ListView.builder(
                    controller: chat.scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    itemCount:
                        chat.messages.length + (chat.isLoading.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= chat.messages.length) {
                        return _TypingBubble(palette: palette);
                      }
                      return _MessageBubble(
                        message: chat.messages[index],
                        palette: palette,
                      );
                    },
                  ),
                ),
                if (!chat.isLoading.value)
                  _SuggestionBar(
                    options: chat.pickableOptions,
                    palette: palette,
                    onPick: chat.sendMessage,
                  ),
                _ChatInputBar(chat: chat, palette: palette),
              ],
            ),
          ],
        ),
      );
    });
  }

  Future<void> _confirmClear(
    BuildContext context,
    ChatbotController chat,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Clear conversation?'),
            content: const Text(
              'This removes all messages from this chat. This cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Clear'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      chat.clearConversation();
      SnackBarComp.show(
        'Conversation cleared.',
        title: 'Chat',
        status: SnackBarCompStatus.success,
      );
    }
  }
}

class _ChatPalette {
  const _ChatPalette({required this.isDark, required this.scheme});

  final bool isDark;
  final ColorScheme scheme;

  Color get primary => primaryColor;
  Color get primaryLight => Color.lerp(primaryColor, Colors.white, 0.22)!;
  Color get primaryDark => Color.lerp(primaryColor, Colors.black, 0.18)!;

  List<Color> get pageGradient =>
      isDark
          ? const [Color(0xFF050D18), Color(0xFF0A1829), Color(0xFF0F2238)]
          : const [Color(0xFFF8FBFF), Color(0xFFEDF5FD), Color(0xFFE3EEF9)];

  Color get glass =>
      isDark
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.white.withValues(alpha: 0.82);

  Color get glassBorder =>
      isDark
          ? primaryColor.withValues(alpha: 0.22)
          : primaryColor.withValues(alpha: 0.16);

  Color get botBubble => isDark ? const Color(0xFF152536) : Colors.white;

  Color get onSurface => isDark ? Colors.white : scheme.onSurface;
  Color get onSurfaceMuted =>
      isDark ? Colors.white.withValues(alpha: 0.62) : scheme.onSurfaceVariant;

  LinearGradient get userBubbleGradient => LinearGradient(
    colors: [primaryDark, primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  LinearGradient get accentGradient => LinearGradient(
    colors: [primary.withValues(alpha: 0.85), primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  List<BoxShadow> get cardShadow => [
    BoxShadow(
      color:
          isDark
              ? Colors.black.withValues(alpha: 0.35)
              : primaryColor.withValues(alpha: 0.08),
      blurRadius: 18,
      offset: const Offset(0, 6),
    ),
  ];
}

class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ChatAppBar({
    required this.botName,
    required this.palette,
    required this.onClear,
  });

  final String botName;
  final _ChatPalette palette;
  final VoidCallback onClear;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: palette.onSurface,
      title: _BotIdentityTitle(botName: botName, palette: palette),
      actions: [
        IconButton(
          tooltip: 'Clear conversation',
          onPressed: onClear,
          icon: Icon(
            Icons.delete_outline_rounded,
            color: palette.onSurfaceMuted,
          ),
        ),
      ],
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  palette.pageGradient.first.withValues(alpha: 0.92),
                  palette.pageGradient.first.withValues(alpha: 0.72),
                ],
              ),
              border: Border(bottom: BorderSide(color: palette.glassBorder)),
            ),
          ),
        ),
      ),
    );
  }
}

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground({required this.palette});

  final _ChatPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: palette.pageGradient,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -60,
            right: -40,
            child: _GlowOrb(
              color: palette.primary.withValues(
                alpha: palette.isDark ? 0.18 : 0.14,
              ),
              size: 200,
            ),
          ),
          Positioned(
            bottom: 120,
            left: -50,
            child: _GlowOrb(
              color: palette.primaryLight.withValues(
                alpha: palette.isDark ? 0.12 : 0.18,
              ),
              size: 160,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: 80, spreadRadius: 20)],
      ),
    );
  }
}

class _BotIdentityTitle extends StatelessWidget {
  const _BotIdentityTitle({required this.botName, required this.palette});

  final String botName;
  final _ChatPalette palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            gradient: palette.accentGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: palette.primary.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.smart_toy_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                botName,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: palette.onSurface,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: const Color(0xFF34D399),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF34D399).withValues(alpha: 0.6),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      'Online · VoxTrade Assistant',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: palette.onSurfaceMuted,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BotAvatar extends StatelessWidget {
  const _BotAvatar({this.size = 30});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withValues(alpha: 0.9),
            primaryColor.withValues(alpha: 0.55),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.32),
        border: Border.all(color: primaryColor.withValues(alpha: 0.35)),
      ),
      child: Icon(
        Icons.smart_toy_rounded,
        size: size * 0.52,
        color: Colors.white,
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.palette});

  final ChatMessage message;
  final _ChatPalette palette;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            const _BotAvatar(size: 28),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: isUser ? palette.userBubbleGradient : null,
                    color: isUser ? null : palette.botBubble,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isUser ? 18 : 5),
                      bottomRight: Radius.circular(isUser ? 5 : 18),
                    ),
                    border:
                        isUser ? null : Border.all(color: palette.glassBorder),
                    boxShadow:
                        isUser
                            ? [
                              BoxShadow(
                                color: palette.primary.withValues(alpha: 0.28),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ]
                            : palette.cardShadow,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    child: SelectableText(
                      message.content,
                      style: textTheme.bodyMedium?.copyWith(
                        color: isUser ? Colors.white : palette.onSurface,
                        height: 1.45,
                        fontWeight: isUser ? FontWeight.w500 : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                if (!isUser)
                  Padding(
                    padding: const EdgeInsets.only(left: 2, top: 2),
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: palette.onSurfaceMuted,
                      ),
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: message.content),
                        );
                        SnackBarComp.show(
                          'Copied to clipboard.',
                          title: 'Chat',
                          status: SnackBarCompStatus.success,
                        );
                      },
                      icon: const Icon(Icons.copy_rounded, size: 13),
                      label: const Text('Copy', style: TextStyle(fontSize: 11)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble({required this.palette});

  final _ChatPalette palette;

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const _BotAvatar(size: 28),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: widget.palette.botBubble,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(5),
              ),
              border: Border.all(color: widget.palette.glassBorder),
              boxShadow: widget.palette.cardShadow,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _ctrl,
                  builder: (_, __) {
                    final t = (_ctrl.value + i * 0.22) % 1.0;
                    final scale = 0.65 + (t < 0.5 ? t : 1 - t) * 0.7;
                    return Container(
                      width: 7,
                      height: 7,
                      margin: EdgeInsets.only(right: i == 2 ? 0 : 6),
                      transform: Matrix4.diagonal3Values(scale, scale, 1),
                      decoration: BoxDecoration(
                        color: widget.palette.primary.withValues(
                          alpha: 0.45 + scale * 0.45,
                        ),
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionBar extends StatelessWidget {
  const _SuggestionBar({
    required this.options,
    required this.palette,
    required this.onPick,
  });

  final List<String> options;
  final _ChatPalette palette;
  final void Function(String) onPick;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
          child: Row(
            children: [
              Icon(
                Icons.tips_and_updates_outlined,
                size: 15,
                color: palette.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Try asking',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: palette.onSurfaceMuted,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: options.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, index) {
              final label = options[index];
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => onPick(label),
                  child: Ink(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          palette.isDark
                              ? palette.primary.withValues(alpha: 0.14)
                              : palette.primary.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: palette.primary.withValues(alpha: 0.32),
                      ),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            palette.isDark
                                ? Colors.white.withValues(alpha: 0.9)
                                : palette.primaryDark,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  const _ChatInputBar({required this.chat, required this.palette});

  final ChatbotController chat;
  final _ChatPalette palette;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
              decoration: BoxDecoration(
                color: palette.glass,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: palette.glassBorder),
                boxShadow: palette.cardShadow,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: chat.inputController,
                      minLines: 1,
                      maxLines: 5,
                      enabled: !chat.isLoading.value,
                      style: TextStyle(
                        color: palette.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ask about VoxTrade features…',
                        hintStyle: TextStyle(color: palette.onSurfaceMuted),
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (_) => chat.sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Obx(() {
                    final canSend =
                        chat.inputText.value.trim().isNotEmpty &&
                        !chat.isLoading.value;
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: canSend ? palette.accentGradient : null,
                        color:
                            canSend
                                ? null
                                : (palette.isDark
                                    ? Colors.white.withValues(alpha: 0.07)
                                    : Colors.black.withValues(alpha: 0.06)),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow:
                            canSend
                                ? [
                                  BoxShadow(
                                    color: palette.primary.withValues(
                                      alpha: 0.35,
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                                : null,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: canSend ? chat.sendMessage : null,
                          child: SizedBox(
                            width: 46,
                            height: 46,
                            child:
                                chat.isLoading.value
                                    ? Padding(
                                      padding: const EdgeInsets.all(11),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color:
                                            palette.isDark
                                                ? Colors.white70
                                                : palette.primary,
                                      ),
                                    )
                                    : Icon(
                                      Icons.arrow_upward_rounded,
                                      color:
                                          canSend
                                              ? Colors.white
                                              : palette.onSurfaceMuted,
                                    ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
