import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voxtrade_core/Components/SnackBar/SnackBarComp.dart';
import 'package:voxtrade_core/assembler/Controller/ThemeController.dart';
import 'package:voxtrade_core/assembler/Controller/Voice_Command_Settings_Controller.dart';
import 'package:voxtrade_core/assembler/common/enum.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final voiceSettings = Get.find<VoiceCommandSettingsController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Obx(() {
          final isDark = themeController.isDarkMode.value;
          final scheme = Theme.of(context).colorScheme;
          final cardColor =
              isDark
                  ? scheme.surfaceContainerHighest.withValues(alpha: 0.55)
                  : scheme.surfaceContainerLow;
          final borderColor =
              isDark
                  ? primaryColor.withValues(alpha: 0.2)
                  : scheme.outlineVariant.withValues(alpha: 0.5);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _sectionTitle(context, 'Appearance'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 18),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Theme',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isDark ? 'Dark theme is active' : 'Light theme is active',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: AnimatedToggleSwitch<bool>.dual(
                        current: !isDark,
                        first: true,
                        second: false,
                        spacing: 50,
                        style: ToggleStyle(
                          borderColor: Colors.transparent,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset: Offset(0, 2),
                            ),
                          ],
                          indicatorColor:
                              !isDark ? Colors.yellow : Colors.grey.shade800,
                        ),
                        onChanged: (isLightMode) {
                          themeController.changeTheme(!isLightMode);
                        },
                        styleBuilder:
                            (isLightMode) => ToggleStyle(
                              indicatorColor:
                                  isLightMode ? Colors.black : Colors.yellow,
                            ),
                        iconBuilder:
                            (isLightMode) =>
                                isLightMode
                                    ? const Icon(
                                      Icons.nights_stay,
                                      color: Colors.blueGrey,
                                    )
                                    : const Icon(
                                      Icons.wb_sunny,
                                      color: Colors.orange,
                                    ),
                        textBuilder:
                            (isLightMode) =>
                                isLightMode
                                    ? const Text(
                                      'Dark',
                                      style: TextStyle(color: Colors.blueGrey),
                                    )
                                    : const Text(
                                      'Light',
                                      style: TextStyle(color: Colors.orange),
                                    ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _sectionTitle(context, 'Voice command models'),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors:
                        isDark
                            ? const [Color(0xff0f1a28), Color(0xff17283d)]
                            : [scheme.primaryContainer, scheme.tertiaryContainer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.mic_rounded, color: primaryColor, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Speech-to-text model',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : scheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose which model processes voice orders from the center mic button.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.white70 : scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Active: ${voiceSettings.selectedModel.title}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              ...VoiceCommandSettingsController.availableModels.map((model) {
                final isSelected = voiceSettings.selectedModelId.value == model.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        voiceSettings.selectModel(model.id);
                        SnackBarComp.show(
                          '${model.title} is now used for voice commands.',
                          title: 'Model updated',
                          status: SnackBarCompStatus.success,
                        );
                      },
                      child: Ink(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color:
                                isSelected
                                    ? primaryColor.withValues(alpha: 0.65)
                                    : borderColor,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_off_rounded,
                              color:
                                  isSelected ? primaryColor : scheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    model.title,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: scheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    model.subtitle,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        }),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w800,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
