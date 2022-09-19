// ignore_for_file: file_names, avoid_print

import 'package:url_launcher/url_launcher.dart';

void launchURL(String url) async {
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  } else {
    throw 'Could not launch $url';
  }
}
