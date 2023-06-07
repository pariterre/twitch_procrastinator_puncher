import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infinite_carousel/infinite_carousel.dart';
import 'package:twitch_pomorodo_timer/models/app_theme.dart';
import 'package:twitch_pomorodo_timer/providers/app_preferences.dart';
import 'package:twitch_pomorodo_timer/providers/participants.dart';

class HallOfFame extends StatefulWidget {
  const HallOfFame({super.key});

  @override
  State<HallOfFame> createState() => _HallOfFameState();
}

class _HallOfFameState extends State<HallOfFame> {
  int _scrollVelocity = 2000;
  final _scrollController = InfiniteScrollController();
  Timer? _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_timer == null) {
      final preferences = AppPreferences.of(context, listen: false);
      _scrollVelocity = preferences.hallOfFameScrollVelocity;
      _timer = Timer.periodic(Duration(milliseconds: _scrollVelocity),
          (Timer t) => _automaticScroller());
    }
  }

  Timer _setupTimer() => Timer.periodic(Duration(milliseconds: _scrollVelocity),
      (Timer t) => _automaticScroller());

  set scrollVelocity(int value) {
    _scrollVelocity = value;
    _timer?.cancel();
    _timer = _setupTimer();
  }

  void _automaticScroller() {
    _scrollController.nextItem(
        duration: Duration(milliseconds: _scrollVelocity),
        curve: Curves.linear);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final windowHeight = MediaQuery.of(context).size.height;
    final preferences = AppPreferences.of(context);
    scrollVelocity = preferences.hallOfFameScrollVelocity;

    final padding = ThemePadding.normal(context);
    final participants = Participants.of(context).all.map((e) => e).toList();

    participants.sort((a, b) => b.doneInAll - a.doneInAll);

    return Container(
      height: windowHeight * 0.3,
      width: windowHeight * 0.6,
      decoration: BoxDecoration(
          color: ThemeColor().main, borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.only(left: padding, top: padding, right: padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                preferences.textHallOfFameTitle.text,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: ThemeColor().hallOfFameText,
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
                  _FameTile(
                    name: preferences.textHallOfFameName.text,
                    doneToday: preferences.textHallOfFameToday.text,
                    doneInAll: preferences.textHallOfFameAlltime.text,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(
                    height: windowHeight * 0.135,
                    child: InfiniteCarousel.builder(
                      physics:
                          const ScrollPhysics(), // Do not try to land on a particular item
                      controller: _scrollController,
                      axisDirection: Axis.vertical,
                      itemCount: participants.length,
                      itemExtent: windowHeight * 0.04,
                      itemBuilder: (ctx, index, realIndex) {
                        final participant = participants[index];
                        return _FameTile(
                          name: participant.username,
                          doneToday: participant.doneToday.toString(),
                          doneInAll: participant.doneInAll.toString(),
                          fontWeight: FontWeight.normal,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              color: Colors.white,
              thickness: windowHeight * 0.002,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: _FameTile(
                name: 'Total',
                doneToday: participants
                    .fold<int>(0, (prev, e) => prev + e.doneToday)
                    .toString(),
                doneInAll: participants
                    .fold<int>(0, (prev, e) => prev + e.doneInAll)
                    .toString(),
                fontWeight: FontWeight.bold,
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
        color: ThemeColor().hallOfFameText,
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
