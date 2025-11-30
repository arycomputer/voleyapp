import 'dart:typed_data';

abstract class FileService {
  Future<void> saveFile({
    required String name,
    required Uint8List bytes,
    required String mimeType,
  });
}
