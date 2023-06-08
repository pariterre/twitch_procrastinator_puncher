import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infinite_carousel/infinite_carousel.dart';
import 'package:twitch_pomorodo_timer/models/app_theme.dart';
import 'package:twitch_pomorodo_timer/providers/app_preferences.dart';
import 'package:twitch_pomorodo_timer/providers/participants.dart';

enum _InitializationStatus {
  notInitiatialized,
  timerInitialized,
  scrollerAttached
}

class HallOfFame extends StatefulWidget {
  const HallOfFame({super.key});

  @override
  State<HallOfFame> createState() => _HallOfFameState();
}

class _HallOfFameState extends State<HallOfFame> {
  int _scrollVelocity = 2000;
  final _scrollController = InfiniteScrollController();
  _InitializationStatus _status = _InitializationStatus.notInitiatialized;
  int _currentItem = -1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_status == _InitializationStatus.notInitiatialized) {
      final preferences = AppPreferences.of(context, listen: false);
      _scrollVelocity = preferences.hallOfFameScrollVelocity;

      // Set the timer that advance the scroller
      Timer.periodic(const Duration(milliseconds: 1), (timer) {
        if (_status == _InitializationStatus.scrollerAttached &&
            _currentItem != _scrollController.selectedItem) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollController.nextItem(
                duration: Duration(milliseconds: _scrollVelocity),
                curve: Curves.linear);
            _currentItem = _scrollController.selectedItem;
          });
        }
      });
      _status = _InitializationStatus.timerInitialized;
    }
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
    _scrollVelocity = preferences.hallOfFameScrollVelocity;

    final padding = ThemePadding.normal(context);
    final participants = Participants.of(context).all.map((e) => e).toList();

    participants.sort((a, b) => b.doneInAll - a.doneInAll);
    _status =
        participants.isEmpty ? _status : _InitializationStatus.scrollerAttached;

    return Container(
      height: windowHeight * 0.3,
      width: windowHeight * 0.6,
      decoration: BoxDecoration(
          color: ThemeColor().hallOfFame,
          borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.only(left: padding, top: padding, right: padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(preferences.textHallOfFameTitle.text,
                  textAlign: TextAlign.center,
                  style: preferences.fontHallOfFame.style(
                    textStyle: TextStyle(
                        color: ThemeColor().hallOfFameText,
                        fontWeight: FontWeight.bold,
                        fontSize: windowHeight * 0.03),
                  )),
            ),
            Divider(
              color: Colors.white,
              thickness: windowHeight * 0.002,
              height: windowHeight * 0.02,
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
                    child: participants.isEmpty
                        ? null
                        : InfiniteCarousel.builder(
                            physics:
                                const ScrollPhysics(), // Do not try to land on a particular item
                            controller: _scrollController,
                            axisDirection: Axis.vertical,
                            itemCount: participants.length,
                            itemExtent: windowHeight * 0.035,
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
              height: windowHeight * 0.02,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: _FameTile(
                name: preferences.textHallOfFameTotal.text,
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
    final preferences = AppPreferences.of(context);

    final textStyle = preferences.fontHallOfFame.style(
        textStyle: TextStyle(
            color: ThemeColor().hallOfFameText,
            fontWeight: fontWeight,
            fontSize: windowHeight * 0.02));

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
