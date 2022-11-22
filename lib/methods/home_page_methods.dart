// ignore_for_file: file_names, avoid_print

import 'package:url_launcher/url_launcher.dart';

String encodeQueryParameters(Map<String, String> params) {
  return params.entries
      .map((MapEntry<String, String> e) =>
          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
}

void launchURL(String url) async {
  final uri = Uri(
    scheme: 'mailto',
    path: url,
    query: encodeQueryParameters(<String, String>{
      'subject': 'Leader\'s Book Issue/Suggestion',
    }),
  );
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    try {
      await launchUrl(uri);
    } catch (e) {
      throw 'Unable to launch url: $url due to exception: $e';
    }
  }
}
