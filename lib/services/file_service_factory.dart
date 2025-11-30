import 'file_service.dart';
import 'file_service_mobile.dart'
    if (dart.library.html) 'file_service_web.dart';

FileService getFileService() => FileServiceImpl();
