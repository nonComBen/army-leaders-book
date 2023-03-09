// ignore_for_file: file_names

import 'package:flutter/material.dart';

class TosPage extends StatelessWidget {
  const TosPage({Key key}) : super(key: key);

  static const routeName = '/terms-of-service-page';

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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms and Conditions'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: width > 916 ? (width - 900) / 2 : 16),
        child: Card(
          child: Container(
            padding: const EdgeInsets.all(8.0),
            constraints: const BoxConstraints(maxWidth: 900),
            child: ListView(
              children: <Widget>[
                normalText('Last updated: July 28'
                    '\n\nPlease read these Terms and Conditions ("Terms", "Terms and Conditions") '
                    'carefully before using the https://armyleadersbook.app website and the Army '
                    'Leader\'s Book mobile application (together, or individually, the "Service") '
                    'operated by Army Leader\'s Book ("us", "we", or "our").'
                    '\n\nYour access to and use of the Service is conditioned upon your acceptance of '
                    'and compliance with these Terms. These Terms apply to all visitors, users and '
                    'others who wish to access or use the Service.'
                    '\n\nBy accessing or using the Service you agree to be bound by these Terms. If you '
                    'disagree with any part of the terms then you do not have permission to access '
                    'the Service.'),
                headerText('Subscriptions'),
                normalText(
                    'Some parts of the Service are billed on a subscription basis '
                    '("Subscription(s)"). You will be billed in advance on a recurring and periodic '
                    'basis ("Billing Cycle"). Billing cycles are set on a annual basis.'
                    '\n\nAt the end of each Billing Cycle, your Subscription will automatically renew '
                    'under the exact same conditions unless you cancel it or Army Leader\'s Book '
                    'cancels it. You may cancel your Subscription renewal either through your '
                    'online account management page or by contacting Army Leader\'s Book customer '
                    'support team.'
                    '\n\nA valid payment method, including credit card, is required to process the '
                    'payment for your Subscription. You shall provide Army Leader\'s Book with '
                    'accurate and complete billing information including full name, address, state, '
                    'zip code, telephone number, and a valid payment method information. By '
                    'submitting such payment information, you automatically authorize Army Leader\'s '
                    'Book to charge all Subscription fees incurred through your account to any such '
                    'payment instruments.'
                    '\n\nShould automatic billing fail to occur for any reason, Army Leader\'s Book will '
                    'issue an electronic invoice indicating that you must proceed manually, within '
                    'a certain deadline date, with the full payment corresponding to the billing '
                    'period as indicated on the invoice.'),
                headerText('Free Trial'),
                normalText(
                    'Army Leader\'s Book may, at its sole discretion, offer a Subscription with a '
                    'free trial for a limited period of time ("Free Trial").'
                    '\n\nYou may be required to enter your billing information in order to sign up for '
                    'the Free Trial.'
                    '\n\nIf you do enter your billing information when signing up for the Free Trial, '
                    'you will not be charged by Army Leader\'s Book until the Free Trial has '
                    'expired. On the last day of the Free Trial period, unless you cancelled your '
                    'Subscription, you will be automatically charged the applicable Subscription '
                    'fees for the type of Subscription you have selected.'
                    '\n\nAt any time and without notice, Army Leader\'s Book reserves the right to (i) '
                    'modify the terms and conditions of the Free Trial offer, or (ii) cancel such '
                    'Free Trial offer.'),
                headerText('Fee Changes'),
                normalText(
                    'Army Leader\'s Book, in its sole discretion and at any time, may modify the '
                    'Subscription fees for the Subscriptions. Any Subscription fee change will '
                    'become effective at the end of the then-current Billing Cycle.'
                    '\n\nArmy Leader\'s Book will provide you with a reasonable prior notice of any '
                    'change in Subscription fees to give you an opportunity to terminate your '
                    'Subscription before such change becomes effective.'
                    '\n\nYour continued use of the Service after the Subscription fee change comes into '
                    'effect constitutes your agreement to pay the modified Subscription fee amount.'),
                headerText('Refunds'),
                normalText(
                    'Certain refund requests for Subscriptions may be considered by Army Leader\'s '
                    'Book on a case-by-case basis and granted in sole discretion of Army Leader\'s '
                    'Book.'),
                headerText('Accounts'),
                normalText(
                    'When you create an account with us, you guarantee that you are above the age '
                    'of 18, and that the information you provide us is accurate, complete, and '
                    'current at all times. Inaccurate, incomplete, or obsolete information may '
                    'result in the immediate termination of your account on the Service.'
                    '\n\nYou are responsible for maintaining the confidentiality of your account and '
                    'password, including but not limited to the restriction of access to your '
                    'computer and/or account. You agree to accept responsibility for any and all '
                    'activities or actions that occur under your account and/or password, whether '
                    'your password is with our Service or a third-party service. You must notify us '
                    'immediately upon becoming aware of any breach of security or unauthorized use '
                    'of your account.'),
                headerText('Intellectual Property'),
                normalText(
                    'The Service and its original content, features and functionality are and will '
                    'remain the exclusive property of Army Leader\'s Book and its licensors. The '
                    'Service is protected by copyright, trademark, and other laws of both the '
                    'United States and foreign countries. Our trademarks and trade dress may not be '
                    'used in connection with any product or service without the prior written '
                    'consent of Army Leader\'s Book.'),
                headerText('Links To Other Web Sites'),
                normalText(
                    'Our Service may contain links to third party web sites or services that are '
                    'not owned or controlled by Army Leader\'s Book'
                    '\n\nArmy Leader\'s Book has no control over, and assumes no responsibility for the '
                    'content, privacy policies, or practices of any third party web sites or '
                    'services. We do not warrant the offerings of any of these entities/individuals '
                    'or their websites.'
                    '\n\nYou acknowledge and agree that Army Leader\'s Book shall not be responsible or '
                    'liable, directly or indirectly, for any damage or loss caused or alleged to be '
                    'caused by or in connection with use of or reliance on any such content, goods '
                    'or services available on or through any such third party web sites or '
                    'services.'
                    '\n\nWe strongly advise you to read the terms and conditions and privacy policies '
                    'of any third party web sites or services that you visit.'),
                headerText('Termination'),
                normalText(
                    'We may terminate or suspend your account and bar access to the Service '
                    'immediately, without prior notice or liability, under our sole discretion, for '
                    'any reason whatsoever and without limitation, including but not limited to a '
                    'breach of the Terms.'
                    '\n\nIf you wish to terminate your account, you may simply discontinue using the '
                    'Service.'
                    '\n\nAll provisions of the Terms which by their nature should survive termination '
                    'shall survive termination, including, without limitation, ownership '
                    'provisions, warranty disclaimers, indemnity and limitations of liability.'),
                headerText('Indemnification'),
                normalText(
                    'You agree to defend, indemnify and hold harmless Army Leader\'s Book and its '
                    'licensee and licensors, and their employees, contractors, agents, officers and '
                    'directors, from and against any and all claims, damages, obligations, losses, '
                    'liabilities, costs or debt, and expenses (including but not limited to '
                    'attorney\'s fees), resulting from or arising out of a) your use and access of '
                    'the Service, by you or any person using your account and password, or b) a '
                    'breach of these Terms.'),
                headerText('Limitation Of Liability'),
                normalText(
                    'In no event shall Army Leader\'s Book, nor its directors, employees, partners, '
                    'agents, suppliers, or affiliates, be liable for any indirect, incidental, '
                    'special, consequential or punitive damages, including without limitation, loss '
                    'of profits, data, use, goodwill, or other intangible losses, resulting from '
                    '(i) your access to or use of or inability to access or use the Service; (ii) '
                    'any conduct or content of any third party on the Service; (iii) any content '
                    'obtained from the Service; and (iv) unauthorized access, use or alteration of '
                    'your transmissions or content, whether based on warranty, contract, tort '
                    '(including negligence) or any other legal theory, whether or not we have been '
                    'informed of the possibility of such damage, and even if a remedy set forth '
                    'herein is found to have failed of its essential purpose.'),
                headerText('Disclaimer'),
                normalText(
                    'Your use of the Service is at your sole risk. The Service is provided on an '
                    '"AS IS" and "AS AVAILABLE" basis. The Service is provided without warranties '
                    'of any kind, whether express or implied, including, but not limited to, '
                    'implied warranties of merchantability, fitness for a particular purpose, non- '
                    'infringement or course of performance.'
                    '\n\nArmy Leader\'s Book its subsidiaries, affiliates, and its licensors do not '
                    'warrant that a) the Service will function uninterrupted, secure or available '
                    'at any particular time or location; b) any errors or defects will be '
                    'corrected; c) the Service is free of viruses or other harmful components; or '
                    'd) the results of using the Service will meet your requirements.'),
                headerText('Exclusions'),
                normalText(
                    'Some jurisdictions do not allow the exclusion of certain warranties or the '
                    'exclusion or limitation of liability for consequential or incidental damages, '
                    'so the limitations above may not apply to you.'),
                headerText('Governing Law'),
                normalText(
                    'These Terms shall be governed and construed in accordance with the laws of '
                    'Pennsylvania, United States, without regard to its conflict of law provisions. '
                    '\n\nOur failure to enforce any right or provision of these Terms will not be '
                    'considered a waiver of those rights. If any provision of these Terms is held '
                    'to be invalid or unenforceable by a court, the remaining provisions of these '
                    'Terms will remain in effect. These Terms constitute the entire agreement '
                    'between us regarding our Service, and supersede and replace any prior '
                    'agreements we might have had between us regarding the Service.'),
                headerText('Changes'),
                normalText(
                    'We reserve the right, at our sole discretion, to modify or replace these Terms '
                    'at any time. If a revision is material we will provide at least 30 days notice '
                    'prior to any new terms taking effect. What constitutes a material change will '
                    'be determined at our sole discretion.'
                    '\n\nBy continuing to access or use our Service after any revisions become '
                    'effective, you agree to be bound by the revised terms. If you do not agree to '
                    'the new terms, you are no longer authorized to use the Service.'),
                headerText('Contact Us'),
                normalText(
                    'If you have any questions about these Terms, please contact us at armynoncomtools@gmail.com.')
              ],
            ),
          ),
        ),
      ),
    );
  }
}
