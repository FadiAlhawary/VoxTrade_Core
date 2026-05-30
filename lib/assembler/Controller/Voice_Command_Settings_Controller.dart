import 'package:get/get.dart';
import 'package:localstorage/localstorage.dart';

class VoiceSttModelOption {
  const VoiceSttModelOption({
    required this.id,
    required this.title,
    required this.subtitle,
  });

  final String id;
  final String title;
  final String subtitle;
}

class VoiceCommandSettingsController extends GetxController {
  static const String storageKey = 'voiceSttModel';
  static const String defaultModelId = 'gpt-4o-transcribe';

  static const List<VoiceSttModelOption> availableModels = [
    VoiceSttModelOption(
      id: 'gpt-4o-transcribe',
      title: 'Strong (gpt-4o-transcribe)',
      subtitle: 'Best accuracy for trading phrases and mixed language.',
    ),
    VoiceSttModelOption(
      id: 'whisper-1',
      title: 'Classic (whisper-1)',
      subtitle: 'Faster and lighter transcription for simple commands.',
    ),
  ];

  final RxString selectedModelId = defaultModelId.obs;

  @override
  void onInit() {
    super.onInit();
    _loadStoredModel();
  }

  void _loadStoredModel() {
    final stored = localStorage.getItem(storageKey);
    if (stored != null && availableModels.any((m) => m.id == stored)) {
      selectedModelId.value = stored;
      return;
    }
    localStorage.setItem(storageKey, defaultModelId);
    selectedModelId.value = defaultModelId;
  }

  VoiceSttModelOption get selectedModel {
    return availableModels.firstWhere(
      (m) => m.id == selectedModelId.value,
      orElse: () => availableModels.first,
    );
  }

  void selectModel(String modelId) {
    if (!availableModels.any((m) => m.id == modelId)) {
      return;
    }
    selectedModelId.value = modelId;
    localStorage.setItem(storageKey, modelId);
  }
}
