import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class HttpService {
  static HttpClient httpClient = HttpClient();
  Future<File> downloadFile(String url, String filename) async {
    final request = await httpClient.getUrl(Uri.parse(url));
    final response = await request.close();
    final bytes = await consolidateHttpClientResponseBytes(response);
    final dir = (await getApplicationDocumentsDirectory()).path;
    final file = File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<List<FileSystemEntity>> listDownloadedFiles() async {
    final dir = Directory((await getApplicationDocumentsDirectory()).path);
    final entities = await dir.list().toList();
    return entities;
  }
}
