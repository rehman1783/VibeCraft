import 'package:flutter_test/flutter_test.dart';
import 'package:vibe_craft/features/ai_creator/data/models/ai_chat_message_model.dart';
import 'package:vibe_craft/features/ai_creator/data/models/generated_image_model.dart';
import 'package:vibe_craft/features/ai_creator/domain/entities/chat_message_entity.dart';
import 'package:vibe_craft/features/ai_creator/domain/repositories/ai_repository.dart';
import 'package:vibe_craft/features/ai_creator/presentation/cubit/ai_chat_cubit.dart';
import 'package:vibe_craft/features/ai_creator/presentation/cubit/ai_chat_state.dart';

class MockAiRepository implements AiRepository {
  String responseToReturn = 'Awesome idea!';
  String wallpaperUrlToReturn = 'https://example.com/test_wallpaper.jpg';

  @override
  Future<String> sendChatMessage({
    required List<ChatMessageEntity> history,
    required String userMessage,
  }) async {
    return responseToReturn;
  }

  @override
  Future<String> generateWallpaper({
    required String prompt,
    String? style,
  }) async {
    return wallpaperUrlToReturn;
  }

  @override
  String synthesizeMasterPrompt(
    List<ChatMessageEntity> history, {
    String? style,
  }) {
    final concepts = history
        .where((m) => m.isUser)
        .map((m) => m.text)
        .join(', ');
    final styleMod = style != null ? '$style, ' : '';
    return 'A high-fidelity 9:16 vertical mobile wallpaper of $concepts, ${styleMod}8k resolution';
  }
}

void main() {
  group('AI Creator Unit Tests', () {
    late MockAiRepository mockAiRepository;
    late AiChatCubit cubit;

    setUp(() {
      mockAiRepository = MockAiRepository();
      cubit = AiChatCubit(aiRepository: mockAiRepository);
    });

    tearDown(() {
      cubit.close();
    });

    test('Initial state has greeting message and initial status', () {
      expect(cubit.state.status, equals(AiChatStatus.initial));
      expect(cubit.state.messages.length, equals(1));
      expect(cubit.state.messages.first.isUser, isFalse);
      expect(cubit.state.messages.first.text, contains('VibeCraft AI'));
    });

    test('sendPrompt directly initiates wallpaper generation without conversational delay', () async {
      await cubit.sendPrompt('Cyberpunk city with neon rain');

      expect(cubit.state.status, equals(AiChatStatus.success));
      expect(cubit.state.generatedImageUrl, equals('https://example.com/test_wallpaper.jpg'));
      expect(cubit.state.generatedWallpaper, isNotNull);
      expect(cubit.state.generatedWallpaper!.altDescription, equals('Cyberpunk city with neon rain'));
      expect(cubit.state.generatedWallpaper!.source, equals('VibeCraft AI'));
    });

    test('selectStyle updates selectedStyle in state', () {
      cubit.selectStyle('Anime Studio');
      expect(cubit.state.selectedStyle, equals('Anime Studio'));
    });

    test('generateWallpaper updates status to success with wallpaper entity and URL', () async {
      await cubit.generateWallpaper('Aesthetic sunset over mountains');

      expect(cubit.state.status, equals(AiChatStatus.success));
      expect(cubit.state.generatedImageUrl, equals('https://example.com/test_wallpaper.jpg'));
      expect(cubit.state.generatedWallpaper, isNotNull);
      expect(cubit.state.generatedWallpaper!.highResUrl, equals('https://example.com/test_wallpaper.jpg'));
      expect(cubit.state.lastPrompt, equals('Aesthetic sunset over mountains'));

      cubit.resetGeneration();
      expect(cubit.state.generatedImageUrl, isNull);
      expect(cubit.state.generatedWallpaper, isNull);
      expect(cubit.state.status, equals(AiChatStatus.responseReceived));
    });

    test('AiChatMessageModel serialization works correctly', () {
      const model = AiChatMessageModel(
        id: 'msg_1',
        text: 'Create a neon wallpaper',
        isUser: true,
        optimizedPrompt: 'Optimized prompt 9:16',
        suggestedStyles: ['Cyberpunk', 'Anime'],
      );

      final json = model.toJson();
      expect(json['id'], equals('msg_1'));
      expect(json['text'], equals('Create a neon wallpaper'));
      expect(json['isUser'], isTrue);
      expect(json['suggestedStyles'], equals(['Cyberpunk', 'Anime']));

      final fromJson = AiChatMessageModel.fromJson(json);
      expect(fromJson.id, equals('msg_1'));
      expect(fromJson.text, equals('Create a neon wallpaper'));
      expect(fromJson.suggestedStyles, contains('Cyberpunk'));
    });

    test('GeneratedImageModel serialization works correctly', () {
      final now = DateTime.now();
      final model = GeneratedImageModel(
        id: 'gen_123',
        prompt: 'Futuristic city',
        imageUrl: 'https://example.com/image.jpg',
        style: 'Cyberpunk',
        createdAt: now,
      );

      final json = model.toJson();
      expect(json['id'], equals('gen_123'));
      expect(json['prompt'], equals('Futuristic city'));
      expect(json['style'], equals('Cyberpunk'));

      final fromJson = GeneratedImageModel.fromJson(json);
      expect(fromJson.id, equals('gen_123'));
      expect(fromJson.imageUrl, equals('https://example.com/image.jpg'));
    });
  });
}
