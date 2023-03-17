import 'package:universal_html/html.dart';

class WebDownload {
  WebDownload({required this.type, required this.fileName, required this.data});
  final String type;
  final String fileName;
  final dynamic data;

  void download() {
    var file = Blob([data], type);
    AnchorElement a = document.createElement("a") as AnchorElement;
    String url = Url.createObjectUrl(file);
    a.href = url;
    a.download = fileName;
    document.body!.append(a);
    a.click();
  }
}
