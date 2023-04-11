import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:leaders_book/widgets/platform_widgets/platform_list_tile.dart';

import '../../pages/tabs/rollup_tab.dart';
import '../methods/date_methods.dart';
import '../methods/theme_methods.dart';
import '../models/setting.dart';

class ShowByNameContent extends StatelessWidget {
  const ShowByNameContent({
    Key? key,
    required this.title,
    required this.list,
    required this.homeCard,
    required this.setting,
    required this.width,
    required this.height,
  }) : super(key: key);
  final String title;
  final List<DocumentSnapshot> list;
  final HomeCard homeCard;
  final Setting setting;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ListView.builder(
        itemCount: list.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          late Card card;
          switch (homeCard) {
            case HomeCard.appointments:
              card = Card(
                color: getContrastingBackgroundColor(context),
                child: PlatformListTile(
                  title: Text(
                      '${list[index]['rank']} ${list[index]['name']}, ${list[index]['firstName']}'),
                  subtitle: title == 'Apts Today'
                      ? Text(
                          '${list[index]['aptTitle']} \nFrom: ${list[index]['start']} To: ${list[index]['end']}')
                      : Text(
                          '${list[index]['aptTitle']} \n${list[index]['date']} \n'
                          'From: ${list[index]['start']} To: ${list[index]['end']}'),
                ),
              );
              break;
            case HomeCard.acft:
              card = Card(
                child: PlatformListTile(
                  title: Text(
                      '${list[index]['rank']} ${list[index]['name']}, ${list[index]['firstName']}'),
                  subtitle: title == 'Overdue ACFTs'
                      ? Text('Last ACFT: ${list[index]['date']}')
                      : Text('Last ACFT: ${list[index]['date']} \n'
                          'MDL: ${list[index]['deadliftScore'].toString()} | SPT: ${list[index]['powerThrowScore'].toString()} | HRP: ${list[index]['puScore'].toString()}'
                          '\nSDC: ${list[index]['dragScore'].toString()} | LTK: ${list[index]['legTuckScore'].toString()} | ${list[index]['altEvent']}: ${list[index]['runScore'].toString()}'
                          '\nScore: ${list[index]['total']}'),
                ),
              );
              break;
            case HomeCard.apft:
              card = Card(
                child: PlatformListTile(
                  title: Text(
                      '${list[index]['rank']} ${list[index]['name']}, ${list[index]['firstName']}'),
                  subtitle: title == 'Overdue APFTs'
                      ? Text('Last APFT: ${list[index]['date']}')
                      : Text('Last APFT: ${list[index]['date']} \n'
                          'PU: ${list[index]['puScore'].toString()} | SU: ${list[index]['suScore'].toString()} | ${list[index]['altEvent']}: ${list[index]['runScore'].toString()}'
                          '\nTotal: ${list[index]['total']}'),
                ),
              );
              break;
            case HomeCard.bf:
              card = Card(
                child: PlatformListTile(
                  title: Text(
                      '${list[index]['rank']} ${list[index]['name']}, ${list[index]['firstName']}'),
                  subtitle: title == 'Overdue Body Compositions'
                      ? Text('Last Ht/Wt: ${list[index]['date']}')
                      : Text(
                          'Last Ht/Wt: ${list[index]['date']} \nBF %: ${list[index]['percent']}'),
                ),
              );
              break;
            case HomeCard.profile:
              card = Card(
                child: PlatformListTile(
                  title: Text(
                      '${list[index]['rank']} ${list[index]['name']}, ${list[index]['firstName']}'),
                  subtitle: title == 'Temp Profiles'
                      ? Text('Exp Date: ${list[index]['exp']}\n'
                          'Recovery Ends: ${list[index]['recExp']}')
                      : Text('Shaving: ${list[index]['shaving'].toString()} \n'
                          'PU: ${list[index]['pu'].toString()} SU: ${list[index]['su']} Run: ${list[index]['run'].toString()}'),
                ),
              );
              break;
            case HomeCard.weapons:
              card = Card(
                child: PlatformListTile(
                  title: Text(
                      '${list[index]['rank']} ${list[index]['name']}, ${list[index]['firstName']}'),
                  subtitle: title == 'Overdue Weapon Quals'
                      ? Text('Last Qual: ${list[index]['date']}')
                      : Text(
                          'Last Qual: ${list[index]['date']} \nScore: ${list[index]['score']} / ${list[index]['max']}'),
                ),
              );
              break;
            case HomeCard.medpros:
              String subtitle =
                  isOverdue(list[index]['pha'], 30 * setting.phaMonths)
                      ? 'PHA: ${list[index]['pha']}\n'
                      : '';
              if (isOverdue(list[index]['dental'], 30 * setting.dentalMonths)) {
                subtitle = '${subtitle}Dental: ${list[index]['dental']}\n';
              }
              if (isOverdue(list[index]['vision'], 30 * setting.visionMonths)) {
                subtitle = '${subtitle}Vision: ${list[index]['vision']}\n';
              }
              if (isOverdue(
                  list[index]['hearing'], 30 * setting.hearingMonths)) {
                subtitle = '${subtitle}Hearing: ${list[index]['hearing']}\n';
              }
              if (isOverdue(list[index]['hiv'], 30 * setting.hivMonths)) {
                subtitle = '${subtitle}HIV: ${list[index]['hiv']}';
              }
              card = Card(
                  child: PlatformListTile(
                title: Text(
                    '${list[index]['rank']} ${list[index]['name']}, ${list[index]['firstName']}'),
                subtitle: Text(subtitle),
              ));
              break;
            case HomeCard.flags:
              card = Card(
                child: PlatformListTile(
                    title: Text(
                        '${list[index]['rank']} ${list[index]['name']}, ${list[index]['firstName']}'),
                    subtitle: Text(
                        '${list[index]['type']} \n${list[index]['date']}')),
              );
              break;
            case HomeCard.training:
              String subtitle = isOverdue(list[index]['cyber'], 365)
                  ? 'Cyber: ${list[index]['cyber']}\n'
                  : '';
              if (isOverdue(list[index]['opsec'], 365)) {
                subtitle = '${subtitle}OPSEC: ${list[index]['opsec']}\n';
              }
              if (isOverdue(list[index]['antiTerror'], 365)) {
                subtitle =
                    '${subtitle}AT Lvl 1: ${list[index]['antiTerror']}\n';
              }
              if (isOverdue(list[index]['lawOfWar'], 365)) {
                subtitle =
                    '${subtitle}Law of War: ${list[index]['lawOfWar']}\n';
              }
              if (isOverdue(list[index]['persRec'], 365)) {
                subtitle =
                    '${subtitle}Personnel Recovery: ${list[index]['persRec']}\n';
              }
              if (isOverdue(list[index]['infoSec'], 365)) {
                subtitle =
                    '${subtitle}Info Security: ${list[index]['infoSec']}\n';
              }
              if (isOverdue(list[index]['ctip'], 365)) {
                subtitle = '${subtitle}CTIP: ${list[index]['ctip']}\n';
              }
              if (isOverdue(list[index]['gat'], 365)) {
                subtitle = '${subtitle}GAT: ${list[index]['gat']}';
              }
              card = Card(
                color: getContrastingBackgroundColor(context),
                child: PlatformListTile(
                    title: Text(
                        '${list[index]['rank']} ${list[index]['name']}, ${list[index]['firstName']}'),
                    subtitle: Text(subtitle)),
              );
              break;
            default:
              null;
          }
          return card;
        },
      ),
    );
  }
}
