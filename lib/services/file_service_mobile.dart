import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';
import 'file_service.dart';

class FileServiceImpl implements FileService {
  @override
  Future<void> saveFile({
    required String name,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    await FileSaver.instance.saveFile(
      name: name,
      bytes: bytes,
      mimeType: MimeType.csv,
    );
  }
}
