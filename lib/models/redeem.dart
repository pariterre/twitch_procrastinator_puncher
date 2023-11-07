import 'package:twitch_procastinator_puncher/providers/app_preferences.dart';

enum Redeem {
  none,
  longerPause,
  longerSession;

  String name(context) {
    final texts = AppPreferences.of(context, listen: false).texts;
    switch (this) {
      case Redeem.none:
        return texts.followerRedeemNone;
      case Redeem.longerPause:
        return texts.followerRedeemLongerPause;
      case Redeem.longerSession:
        return texts.followerRedeemLongerSession;
    }
  }
}
