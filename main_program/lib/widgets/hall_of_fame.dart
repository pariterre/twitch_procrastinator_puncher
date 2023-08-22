import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infinite_carousel/infinite_carousel.dart';
import 'package:twitch_procastinator_puncher/models/app_theme.dart';
import 'package:twitch_procastinator_puncher/providers/app_preferences.dart';
import 'package:twitch_procastinator_puncher/providers/participants.dart';

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
  final _scrollController = InfiniteScrollController();
  _InitializationStatus _status = _InitializationStatus.notInitiatialized;
  bool _isMoving = false;

  Future<void> _delay() async {
    _isMoving = true;
    final preferences = AppPreferences.of(context, listen: false);
    await Future.delayed(
        Duration(milliseconds: preferences.hallOfFameScrollVelocity.value));
    _isMoving = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final preferences = AppPreferences.of(context, listen: false);

    if (_status == _InitializationStatus.notInitiatialized) {
      // Set the timer that advance the scroller
      Timer.periodic(const Duration(milliseconds: 10), (timer) {
        if (!preferences.useHallOfFame.value) {
          // Stop the timer if there is no hall of fame
          timer.cancel();
          return;
        }
        if (_status == _InitializationStatus.scrollerAttached) {
          if (!_isMoving) {
            _delay();
            _scrollController.nextItem(
                duration: Duration(
                    milliseconds: preferences.hallOfFameScrollVelocity.value),
                curve: Curves.linear);
          }
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

    final padding = ThemePadding.normal(context);
    final participants = Participants.of(context).all.map((e) => e).toList();

    participants.sort((a, b) => b.sessionsDone - a.sessionsDone);
    _status =
        participants.isEmpty ? _status : _InitializationStatus.scrollerAttached;

    return Container(
      height: windowHeight * 0.3,
      width: windowHeight * 0.6,
      decoration: BoxDecoration(
          color: preferences.backgroundColorHallOfFame.value,
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
                        color: preferences.textHallOfFameTitle.color,
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
                    color: preferences.textColorHallOfFame,
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
                                doneToday:
                                    participant.sessionsDoneToday.toString(),
                                doneInAll: participant.sessionsDone.toString(),
                                fontWeight: FontWeight.normal,
                                color: preferences.textColorHallOfFame,
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
                    .fold<int>(0, (prev, e) => prev + e.sessionsDoneToday)
                    .toString(),
                doneInAll: participants
                    .fold<int>(0, (prev, e) => prev + e.sessionsDone)
                    .toString(),
                fontWeight: FontWeight.bold,
                color: preferences.textHallOfFameTotal.color,
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
    required this.color,
  });

  final String name;
  final String doneToday;
  final String doneInAll;
  final FontWeight fontWeight;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final windowHeight = MediaQuery.of(context).size.height;
    final preferences = AppPreferences.of(context);

    final textStyle = preferences.fontHallOfFame.style(
        textStyle: TextStyle(
            color: color,
            fontWeight: fontWeight,
            fontSize: windowHeight * 0.02));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
            width: windowHeight * 0.3,
            child: Text(name, style: textStyle.copyWith())),
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
