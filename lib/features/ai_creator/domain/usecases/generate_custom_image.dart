import '../repositories/ai_repository.dart';

class GenerateCustomImageUseCase {
  final AiRepository repository;

  const GenerateCustomImageUseCase(this.repository);

  Future<String> call({
    required String prompt,
    String? style,
  }) async {
    return await repository.generateWallpaper(
      prompt: prompt,
      style: style,
    );
  }
}
