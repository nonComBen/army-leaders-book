// ignore_for_file: file_names

import 'package:universal_html/html.dart';

class WebDownload {
  WebDownload({this.type, this.fileName, this.data});
  final String type;
  final String fileName;
  final dynamic data;

  void download() {
    var file = Blob([data], type);
    AnchorElement a = document.createElement("a");
    String url = Url.createObjectUrl(file);
    a.href = url;
    a.download = fileName;
    document.body.append(a);
    a.click();
  }
}
