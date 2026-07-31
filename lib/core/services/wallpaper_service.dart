import 'dart:io';
import 'package:flutter/services.dart';

class WallpaperService {
  static const MethodChannel _channel = MethodChannel('com.vibecraft.app/wallpaper');

  /// Constants for wallpaper targets matching native implementation
  static const int targetHome = 1;
  static const int targetLock = 2;
  static const int targetBoth = 3;

  /// Sets local image file as wallpaper on Android device.
  /// Returns `true` on success, or throws an exception on failure.
  Future<bool> setWallpaper({
    required String filePath,
    required int target,
  }) async {
    if (filePath.isEmpty) {
      throw Exception('File path cannot be empty.');
    }

    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Wallpaper file does not exist at target path: $filePath');
    }

    try {
      final bool? result = await _channel.invokeMethod<bool>(
        'setWallpaper',
        {
          'filePath': filePath,
          'target': target,
        },
      );
      return result ?? false;
    } on PlatformException catch (e) {
      throw Exception(e.message ?? 'Platform error setting wallpaper.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

