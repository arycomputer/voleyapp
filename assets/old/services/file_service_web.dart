import 'dart:typed_data';
import 'package:universal_html/html.dart' as html;
import 'file_service.dart';

class FileServiceImpl implements FileService {
  @override
  Future<void> saveFile({
    required String name,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute("download", name)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
