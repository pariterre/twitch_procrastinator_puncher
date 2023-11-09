import 'package:twitch_procastinator_puncher/providers/app_preferences.dart';

enum RewardRedemption {
  none,
  longerPause,
  longerSession;

  String name(context) {
    final texts = AppPreferences.of(context, listen: false).texts;
    switch (this) {
      case RewardRedemption.none:
        return texts.rewardRedemptionNone;
      case RewardRedemption.longerPause:
        return texts.rewardRedemptionLongerPause;
      case RewardRedemption.longerSession:
        return texts.rewardRedemptionLongerSession;
    }
  }
}
