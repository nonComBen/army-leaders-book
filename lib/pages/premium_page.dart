import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';
import 'package:leaders_book/methods/theme_methods.dart';
import 'package:leaders_book/widgets/bullet_text.dart';
import 'package:leaders_book/widgets/platform_widgets/platform_loading_widget.dart';

import '../../widgets/platform_widgets/platform_button.dart';
import '../../widgets/standard_text.dart';
import '../../widgets/logo_widget.dart';
import '../../widgets/platform_widgets/platform_scaffold.dart';
import '../../widgets/upload_frame.dart';
import '../../widgets/header_text.dart';
import '../methods/toast_messages/show_toast.dart';
import '../models/purchasable_product.dart';
import '../providers/subscription_purchases.dart';

class PremiumPage extends ConsumerStatefulWidget {
  const PremiumPage({super.key});

  static const String routeName = '/premium-page';

  @override
  ConsumerState<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends ConsumerState<PremiumPage> {
  bool storeAvailable = false, isLoading = false;
  late SubscriptionPurchases sp;
  late DateTime date;
  late DateFormat dateFormat;
  late String store;

  @override
  void initState() {
    super.initState();
    InAppPurchase.instance.isAvailable().then((value) {
      setState(() {
        storeAvailable = value;
      });
    });
    sp = ref.read(subscriptionPurchasesProvider);
    date = DateTime.now().add(const Duration(days: 365));
    dateFormat = DateFormat('yyyy-MM-dd');
    store = Platform.isAndroid ? 'Google Play Store' : 'App Store';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return PlatformScaffold(
      title: 'Premium Subscription',
      body: Stack(
        children: [
          UploadFrame(
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
                  'on ${dateFormat.format(date)} unless canceled through the $store.',
                  textAlign: TextAlign.center,
                ),
              ),
              PlatformButton(
                onPressed: () async {
                  if (storeAvailable || sp.products.isNotEmpty) {
                    PurchasableProduct product;
                    if (Platform.isAndroid) {
                      product = sp.products
                          .firstWhere((element) => element.id == 'ad_free_two');
                    } else {
                      product = sp.products
                          .firstWhere((element) => element.id == 'premium_sub');
                    }
                    setState(() {
                      isLoading = true;
                    });
                    sp.buy(product).then((value) {
                      setState(() {
                        isLoading = false;
                      });
                    });
                  } else {
                    showToast(context,
                        'Store is not available. Please try again in a few seconds.');
                  }
                },
                child: const Text('Subscribe'),
              ),
            ],
          ),
          if (isLoading)
            Center(
              child: SizedBox(
                width: width / 2,
                height: width / 2,
                child: Card(
                  color: Colors.transparent,
                  child: PlatformLoadingWidget(
                    color: getTextColor(context),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
