import 'package:flutter_test/flutter_test.dart';
import 'package:leaders_book/models/soldier.dart';
import 'package:leaders_book/providers/filtered_soldiers_provider.dart';

List<Soldier> allSoldiers = [
  Soldier(
      owner: 'owner',
      users: ['users'],
      lastName: 'Hultquist',
      rank: 'SFC',
      section: 'S1'),
  Soldier(
      owner: 'owner',
      users: ['users'],
      lastName: 'Bruce',
      rank: 'SFC',
      section: 'S3'),
  Soldier(
      owner: 'owner',
      users: ['users'],
      lastName: 'Lopez',
      rank: 'SFC',
      section: 'S2'),
  Soldier(
      owner: 'owner',
      users: ['users'],
      lastName: 'Rocks',
      rank: 'SFC',
      section: 'Company'),
  Soldier(
      owner: 'owner',
      users: ['users'],
      lastName: 'Jun',
      rank: 'SFC',
      section: 'S4'),
];

void main() {
  late FilteredSoldiers sut;

  setUp(() {
    sut = FilteredSoldiers(allSoldiers);
  });

  test('initial values are correct', () {
    expect(sut.soldiers, allSoldiers);
  });

  group('filtering Soldiers', () {
    test(
      "filtering Soldiers works",
      () async {
        List<String> sections = ['S1', 'S2'];
        sut.filter(sections);
        expect(sut.soldiers.length, 2);
        expect(
            sut.soldiers,
            allSoldiers
                .where((element) => sections.contains(element.section))
                .toList());
      },
    );
  });
}
