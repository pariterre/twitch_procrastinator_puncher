import 'package:twitch_procastinator_puncher/providers/app_preferences.dart';

enum RewardRedemption {
  none,
  addTimeToCurrentTimer,
  nextPauseIsLonger,
  nextSessionIslonger;

  String name(context) {
    final texts = AppPreferences.of(context, listen: false).texts;
    switch (this) {
      case RewardRedemption.none:
        return texts.rewardRedemptionNone;
      case RewardRedemption.addTimeToCurrentTimer:
        return texts.rewardRedemptionAddTime;
      case RewardRedemption.nextPauseIsLonger:
        return texts.rewardRedemptionNextPauseIsLonger;
      case RewardRedemption.nextSessionIslonger:
        return texts.rewardRedemptionNextSessionIsLonger;
    }
  }

  bool get takesEffectNow {
    switch (this) {
      case RewardRedemption.none:
        return false;
      case RewardRedemption.addTimeToCurrentTimer:
        return true;
      case RewardRedemption.nextPauseIsLonger:
        return false;
      case RewardRedemption.nextSessionIslonger:
        return false;
    }
  }

  bool get isTimeRelated {
    switch (this) {
      case RewardRedemption.none:
        return false;
      case RewardRedemption.addTimeToCurrentTimer:
        return true;
      case RewardRedemption.nextPauseIsLonger:
        return true;
      case RewardRedemption.nextSessionIslonger:
        return true;
    }
  }
}
