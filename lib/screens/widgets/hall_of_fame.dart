import 'package:flutter/material.dart';
import 'package:twitch_pomorodo_timer/models/app_theme.dart';
import 'package:twitch_pomorodo_timer/models/participant.dart';
import 'package:twitch_pomorodo_timer/providers/app_preferences.dart';

class HallOfFame extends StatelessWidget {
  const HallOfFame({super.key});

  @override
  Widget build(BuildContext context) {
    final windowHeight = MediaQuery.of(context).size.height;
    final preferences = AppPreferences.of(context);
    final padding = ThemePadding.normal(context);

    final allParticipants = [
      Participant(username: 'Coucou', doneToday: 10, doneInAll: 100),
      Participant(username: 'Coucou5', doneToday: 5, doneInAll: 14),
      Participant(username: 'Coucou4', doneToday: 1, doneInAll: 50),
      Participant(username: 'Coucou3', doneToday: 13, doneInAll: 10),
      Participant(username: 'Coucou2', doneToday: 50, doneInAll: 200),
    ];
    allParticipants.sort((a, b) => b.doneInAll - a.doneInAll);

    return Container(
      height: windowHeight * 0.3,
      width: windowHeight * 0.6,
      decoration: BoxDecoration(
          color: ThemeColor.main, borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.only(left: padding, top: padding, right: padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                preferences.textHallOfFameTitle.text,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: ThemeColor.text,
                    fontWeight: FontWeight.bold,
                    fontSize: windowHeight * 0.03),
              ),
            ),
            Divider(
              color: Colors.white,
              thickness: windowHeight * 0.002,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Column(
                children: [
                  const _FameTile(
                    name: 'Nom des bleuets',
                    doneToday: 'Aujourd\'hui',
                    doneInAll: 'En tout',
                    fontWeight: FontWeight.bold,
                  ),
                  ...allParticipants
                      .map<Widget>((e) => _FameTile(
                            name: e.username,
                            doneToday: e.doneToday.toString(),
                            doneInAll: e.doneInAll.toString(),
                            fontWeight: FontWeight.normal,
                          ))
                      .toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FameTile extends StatelessWidget {
  const _FameTile({
    required this.name,
    required this.doneToday,
    required this.doneInAll,
    required this.fontWeight,
  });

  final String name;
  final String doneToday;
  final String doneInAll;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    final windowHeight = MediaQuery.of(context).size.height;
    final textStyle = TextStyle(
        color: ThemeColor.text,
        fontWeight: fontWeight,
        fontSize: windowHeight * 0.02);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
            width: windowHeight * 0.3, child: Text(name, style: textStyle)),
        SizedBox(
            width: windowHeight * 0.12,
            child: Text(
              doneToday,
              style: textStyle,
              textAlign: TextAlign.center,
            )),
        SizedBox(
            width: windowHeight * 0.12,
            child: Text(
              doneInAll,
              style: textStyle,
              textAlign: TextAlign.center,
            )),
      ],
    );
  }
}
