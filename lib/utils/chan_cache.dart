import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_chan_viewer/utils/network_image/cache_directive.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class ChanCache {
  static final ChanCache _repo = new ChanCache._internal();
  static bool _initialized = false;

  static const String BASE_DIR = "ChanViewer";
  static const String CONTENT_FILENAME = "content.json";
  static const String SEPARATOR = "/";

  Directory _baseDirectory;

  ChanCache._internal() {
    // initialization code
  }

  static ChanCache get() {
    if (!_initialized) throw Exception("Cache must be initialized at first!");
    return _repo;
  }

  static Future<void> init() async {
    _repo._baseDirectory = Directory(join((await getTemporaryDirectory()).path, BASE_DIR));
    if (!_repo._baseDirectory.existsSync()) await _repo._baseDirectory.create();
    _initialized = true;
  }

  bool mediaFileExists(String url, CacheDirective cacheDirective) => File(join(_baseDirectory.path, _getFileRelativePath(url, cacheDirective))).existsSync();

  bool contentFileExists(CacheDirective cacheDirective) => File(join(_baseDirectory.path, _getFolderRelativePath(cacheDirective), CONTENT_FILENAME)).existsSync();

  List<String> listDirectory(CacheDirective cacheDirective) =>
      Directory(join(_baseDirectory.path, _getFolderRelativePath(cacheDirective))).listSync(recursive: true).map((file) => file.path);

  String _getFolderRelativePath(CacheDirective cacheDirective) => "${cacheDirective.boardId}$SEPARATOR${cacheDirective.threadId}";

  String _getFileRelativePath(String url, CacheDirective cacheDirective) => "${cacheDirective.boardId}$SEPARATOR${cacheDirective.threadId}$SEPARATOR${_getFileName(url)}";

  String _getFileName(String url) => url.substring(url.lastIndexOf(SEPARATOR) + 1);

  Future<Uint8List> getMediaFile(String url, CacheDirective cacheDirective) async {
    try {
      File mediaFile = File(join(_baseDirectory.path, _getFileRelativePath(url, cacheDirective)));
      Uint8List data = await mediaFile.readAsBytes();
      return data;
    } catch (e) {
      print("File read error! ${e.toString()}");
    }
    return null;
  }

  Future<File> writeMediaFile(String url, CacheDirective cacheDirective, Uint8List data) async {
    try {
      Directory directory = Directory(join(_baseDirectory.path, _getFolderRelativePath(cacheDirective)));
      if (!directory.existsSync()) await directory.create(recursive: true);

      File mediaFile = File(join(directory.path, _getFileName(url)));
      print("Writing media { relative path: ${_getFileRelativePath(url, cacheDirective)}, mediaFile: ${mediaFile.path} }");
      File result = await mediaFile.writeAsBytes(data, flush: false);
      return result;
    } catch (e) {
      print("File write error! ${e.toString()}");
    }
    return null;
  }

  Future<String> _readContentString(CacheDirective cacheDirective) async {
    try {
      Directory directory = Directory(join(_baseDirectory.path, _getFolderRelativePath(cacheDirective)));
      File file = File(join(directory.path, CONTENT_FILENAME));
      String text = await file.readAsString();
      return text;
    } catch (e) {
      print("Couldn't read string from ${_getFolderRelativePath(cacheDirective)}");
      return null;
    }
  }

  _saveContentString(CacheDirective cacheDirective, String content) async {
    try {
      Directory directory = Directory(join(_baseDirectory.path, _getFolderRelativePath(cacheDirective)));
      if (!directory.existsSync()) await directory.create(recursive: true);

      File file = File(join(directory.path, CONTENT_FILENAME));
      File result = await file.writeAsString(content);
      return result;
    } catch (e) {
      print("Couldn't write string to ${_getFolderRelativePath(cacheDirective)}");
      return null;
    }
  }
}
