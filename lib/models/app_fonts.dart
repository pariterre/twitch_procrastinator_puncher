import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppFonts {
  abel,
  alegreya,
  amatic,
  annie,
  bilbo,
  caveat,
  cinzel,
  cormoran,
  dancing,
  dawning,
  lato,
  mansalva,
  marcellus,
  parisienne,
  pressStart,
  raleway,
  shadows,
}

extension AppFontsString on AppFonts {
  TextStyle Function({TextStyle? textStyle}) get style {
    switch (this) {
      case AppFonts.abel:
        return GoogleFonts.abel;
      case AppFonts.alegreya:
        return GoogleFonts.alegreyaSansSc;
      case AppFonts.amatic:
        return GoogleFonts.amaticSc;
      case AppFonts.annie:
        return GoogleFonts.annieUseYourTelescope;
      case AppFonts.bilbo:
        return GoogleFonts.bilbo;
      case AppFonts.caveat:
        return GoogleFonts.caveat;
      case AppFonts.cinzel:
        return GoogleFonts.cinzel;
      case AppFonts.cormoran:
        return GoogleFonts.cormorantSc;
      case AppFonts.dancing:
        return GoogleFonts.dancingScript;
      case AppFonts.dawning:
        return GoogleFonts.dawningOfANewDay;
      case AppFonts.lato:
        return GoogleFonts.lato;
      case AppFonts.parisienne:
        return GoogleFonts.parisienne;
      case AppFonts.mansalva:
        return GoogleFonts.mansalva;
      case AppFonts.marcellus:
        return GoogleFonts.marcellusSc;
      case AppFonts.pressStart:
        return GoogleFonts.pressStart2p;
      case AppFonts.raleway:
        return GoogleFonts.raleway;
      case AppFonts.shadows:
        return GoogleFonts.shadowsIntoLight;
    }
  }
}
