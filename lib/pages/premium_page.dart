import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';
import 'package:leaders_book/widgets/bullet_text.dart';

import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/standard_text.dart';
import '../../widgets/logo_widget.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';
import '../../widgets/upload_frame.dart';
import '../../widgets/header_text.dart';
import '../methods/toast_messages.dart/show_toast.dart';
import '../models/purchasable_product.dart';
import '../providers/subscription_purchases.dart';

class PremiumPage extends ConsumerWidget {
  const PremiumPage({super.key});

  static const String routeName = '/premium-page';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = DateTime.now().add(const Duration(days: 365));
    final dateFormat = DateFormat('yyyy-MM-dd');
    final store = Platform.isAndroid ? 'Google Play Store' : 'App Store';
    final sp = ref.read(subscriptionPurchasesProvider);
    return PlatformScaffold(
      title: 'Premium Subscription',
      body: UploadFrame(
        children: [
          const LogoWidget(
            vertPadding: 24,
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: HeaderText('Benefits'),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                BulletText(
                    text:
                        'Allows you to upload data via Excel file for easier input'),
                BulletText(
                    text:
                        'Allows you to download data to pdf file for creating sublementary hardcopy leader\'s book'),
                BulletText(text: 'Removes ads'),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: HeaderText('Price'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: StandardText(
                'The Premium subscription cost \$1.99 per year and will automatically renew '
                'on ${dateFormat.format(date)} unless canceled through the $store.'),
          ),
          PlatformButton(
            onPressed: () async {
              InAppPurchase.instance.isAvailable().then((isAvailable) async {
                if (isAvailable) {
                  PurchasableProduct product;
                  if (Platform.isAndroid) {
                    product = sp.products
                        .firstWhere((element) => element.id == 'ad_free_two');
                  } else {
                    product = sp.products
                        .firstWhere((element) => element.id == 'premium_sub');
                  }
                  await sp.buy(product);
                } else {
                  showToast(context, 'Store is not available');
                }
              });
            },
            child: const Text('Subscribe'),
          ),
        ],
      ),
    );
  }
}
