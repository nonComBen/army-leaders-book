import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key key}) : super(key: key);

  static const routeName = '/privacy-policy-page';

  Widget headerText(String text) {
    return Padding(
        padding: const EdgeInsets.all(4.0),
        child: SelectableText(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
        ));
  }

  Widget normalText(String text) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: SelectableText(text),
    );
  }

  _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: width > 916 ? (width - 900) / 2 : 16),
        child: Card(
          child: Container(
            padding: const EdgeInsets.all(8.0),
            constraints: const BoxConstraints(maxWidth: 900),
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                normalText(
                    '\n\nArmy NonCom Tools built the Army Leader\'s Book app as a Freemium app. '
                    'This SERVICE is provided by Army NonCom Tools at no cost and is intended for use as is.'
                    '\n\nThis page is used to inform visitors regarding our policies with the collection, '
                    'use, and disclosure of Personal Information if anyone decided to use our Service.'
                    '\n\nIf you choose to use our Service, then you agree to the collection and use of '
                    'information in relation to this policy. The Personal Information that we collect '
                    'is used for providing and improving the Service. We will not use or share your '
                    'information with anyone except as described in this Privacy Policy.'
                    '\n\nThe terms used in this Privacy Policy have the same meanings as in our Terms '
                    'and Conditions, which is accessible at Army Leader\'s Book unless otherwise '
                    'defined in this Privacy Policy.'),
                headerText('Information Collection and Use'),
                normalText(
                    'For a better experience, while using our Service, we may require you to provide us '
                    'with certain personally identifiable information, including but not limited to '
                    'Name, Email Address, Device Information, Cookies, Geographical Information, and '
                    'Advertising Id. The information that we request will be retained by us and used '
                    'as described in this privacy policy. In addition to information requested by us, '
                    'Army Leader\'s Book has input fields for First Name, Last Name, Phone Number, '
                    'License Plate, Military License Number, '
                    'Medical Appointments, and Physical Profile. Third third-party services do not have '
                    'access to this data and we do not use it for any purposes.'
                    '\n\nThe app does use third party services that may collect information used to identify you.'
                    '\n\nLink to privacy policy of third party service providers used by the app'),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: Tooltip(
                    message: 'https://policies.google.com/privacy',
                    child: GestureDetector(
                      onTap: () {
                        _launchURL('https://policies.google.com/privacy');
                      },
                      child: const Text(
                        ' - Google Play Services',
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: Tooltip(
                    message:
                        'https://support.google.com/admob/answer/6128543?hl=en',
                    child: GestureDetector(
                      onTap: () {
                        _launchURL(
                            'https://support.google.com/admob/answer/6128543?hl=en');
                      },
                      child: const Text(
                        ' - AdMob',
                        style: TextStyle(color: Colors.blue),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: Tooltip(
                    message: 'https://firebase.google.com/policies/analytics',
                    child: GestureDetector(
                      onTap: () {
                        _launchURL(
                            'https://firebase.google.com/policies/analytics');
                      },
                      child: const Text(
                        ' - Firebase Analytics',
                        style: TextStyle(color: Colors.blue),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                ),
                headerText('Log Data'),
                normalText(
                    'We want to inform you that whenever you use our Service, in a case of an error in the '
                    'app we collect data and information (through third party products) on your phone '
                    'called Log Data. This Log Data may include information such as your device Internet '
                    'Protocol (“IP”) address, device name, operating system version, the configuration '
                    'of the app when utilizing our Service, the time and date of your use of the Service, '
                    'and other statistics.'),
                headerText('Cookies'),
                normalText(
                    'Cookies are files with a small amount of data that are commonly used as anonymous '
                    'unique identifiers. These are sent to your browser from the websites that you visit '
                    'and are stored on your device\'s internal memory.'
                    '\n\nThis Service does not use these “cookies” explicitly. However, the app may use '
                    'third party code and libraries that use “cookies” to collect information and improve '
                    'their services. You have the option to either accept or refuse these cookies and know '
                    'when a cookie is being sent to your device. If you choose to refuse our cookies, you '
                    'may not be able to use some portions of this Service.'),
                headerText('Service Providers'),
                normalText(
                    'We may employ third-party companies and individuals due to the following reasons:'
                    '\n\n - To facilitate our Service;'
                    '\n - To provide the Service on our behalf;'
                    '\n - To perform Service-related services; or'
                    '\n - To assist us in analyzing how our Service is used.'
                    '\n\nWe want to inform users of this Service that these third parties have access to your '
                    'Personal Information. The reason is to perform the tasks assigned to them on our behalf. '
                    'However, they are obligated not to disclose or use the information for any other purpose.'),
                headerText('Security'),
                normalText(
                    'We value your trust in providing us your Personal Information, thus we are striving to use '
                    'commercially acceptable means of protecting it. But remember that no method of transmission '
                    'over the internet, or method of electronic storage is 100% secure and reliable, and we '
                    'cannot guarantee its absolute security.'),
                headerText('Links to Other Sites'),
                normalText(
                    'This Service may contain links to other sites. If you click on a third-party link, you will be '
                    'directed to that site. Note that these external sites are not operated by us. Therefore, '
                    'we strongly advise you to review the Privacy Policy of these websites. We have no control '
                    'over and assume no responsibility for the content, privacy policies, or practices of any '
                    'third-party sites or services.'),
                headerText('Children’s Privacy'),
                normalText(
                    'In the past, Army Leader\'s Book had input fields for children\'s name and date of birth. That '
                    'section has been removed from the app and the data deleted from the database. In the case '
                    'we discover any further information on a child under 13, we will immediately delete this '
                    'from the database. If you are a parent or guardian and you are aware that your child has '
                    'provided us with personal information, please contact us so that we will be able to do necessary '
                    'actions.'),
                headerText('Changes to This Privacy Policy'),
                normalText(
                    'We may update our Privacy Policy from time to time. Thus, you are advised to review this page '
                    'periodically for any changes. We will notify you of any changes by posting the new Privacy '
                    'Policy on this page. These changes are effective immediately after they are posted on this page.'),
                headerText('Contact Us'),
                normalText(
                    'If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us '
                    'at armynoncomtools@gmail.com.'
                    '\n\nThis privacy policy page was created at privacypolicytemplate.net and modified/generated by '
                    'App Privacy Policy Generator'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
