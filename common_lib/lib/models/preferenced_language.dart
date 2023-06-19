import 'package:common_lib/models/config.dart';
import 'package:common_lib/models/preferenced_element.dart';

enum Language {
  english,
  french,
}

class PreferencedLanguage extends PreferencedElement {
  @override
  PreferencedLanguage(this._current);

  int serialize() {
    return _current.index;
  }

  static PreferencedLanguage deserialize(map, [int defaultValue = 0]) =>
      PreferencedLanguage(Language.values[map ?? defaultValue]);

  Language _current;
  Language get language => _current;
  set language(Language value) {
    _current = value;
    if (onChanged != null) onChanged!();
  }

  @override
  String toString() {
    return _current.toString();
  }

  String get titleMain {
    switch (_current) {
      case Language.english:
        return 'The Procrastinator Puncher';
      case Language.french:
        return 'Le Chasseur de Procrastination';
    }
  }

  String get titleDescription1 {
    switch (_current) {
      case Language.english:
        return 'This is the configuration software for the timer of the '
            'Procrastinator Puncher! To import it into your streaming platform, '
            'you have two options:\n'
            '\n'
            '    1. Grab the current window\n'
            '    2. Add a browser source that points to ';
      case Language.french:
        return 'Ceci est le logiciel de configuration pour le minuteur du '
            'Chasseur de Procrastination ! Pour l\'importer dans votre '
            'plateforme de diffusion en continu, vous avez deux options :\n'
            '\n'
            '    1. Capturez la fenêtre actuelle\n'
            '    2. Ajoutez une source de navigateur qui pointe vers ';
    }
  }

  String get titleDescription2 {
    switch (_current) {
      case Language.english:
        return '\n'
            'Please note that you still need to have the configuration software '
            'up and running in order to connect to the web client.';
      case Language.french:
        return '\n'
            'Veuillez noter que vous devez toujours avoir le logiciel de '
            'configuration en cours d\'exécution pour vous connecter au client web';
    }
  }

  String get controllerTitle {
    switch (_current) {
      case Language.english:
        return 'Pomodoro controller';
      case Language.french:
        return 'Contrôles du minuteur';
    }
  }

  String get controllerStartTimer {
    switch (_current) {
      case Language.english:
        return 'Start timer';
      case Language.french:
        return 'Lancer minuteur';
    }
  }

  String get controllerPauseTimer {
    switch (_current) {
      case Language.english:
        return 'Pause timer';
      case Language.french:
        return 'Pauser minuteur';
    }
  }

  String get controllerResumeTimer {
    switch (_current) {
      case Language.english:
        return 'Resume timer';
      case Language.french:
        return 'Relancer minuteur';
    }
  }

  String get controllerResetTimer {
    switch (_current) {
      case Language.english:
        return 'Reset timer';
      case Language.french:
        return 'Remise à zéro';
    }
  }

  String get controllerConnectTwitch {
    switch (_current) {
      case Language.english:
        return 'Connect to Twitch';
      case Language.french:
        return 'Connecter à Twitch';
    }
  }

  String get controllerReconnectTwitch {
    switch (_current) {
      case Language.english:
        return 'Reconnect to Twitch';
      case Language.french:
        return 'Reconnecter à Twitch';
    }
  }

  String get controllerNumberOfSession {
    switch (_current) {
      case Language.english:
        return 'Number of sessions';
      case Language.french:
        return 'Nombre de séances';
    }
  }

  String get controllerSessionDuration {
    switch (_current) {
      case Language.english:
        return 'Session duration (mm:ss)';
      case Language.french:
        return 'Durée des séances (mm:ss)';
    }
  }

  String get controllerPauseDuration {
    switch (_current) {
      case Language.english:
        return 'Pause duration (mm:ss)';
      case Language.french:
        return 'Nombre des pauses (mm:ss)';
    }
  }

  String get filesActiveImage {
    switch (_current) {
      case Language.english:
        return 'Image during sessions';
      case Language.french:
        return 'Image durant les séances';
    }
  }

  String get filesPauseImage {
    switch (_current) {
      case Language.english:
        return 'Image during pauses';
      case Language.french:
        return 'Image durant les pauses';
    }
  }

  String get filesEndActiveSound {
    switch (_current) {
      case Language.english:
        return 'Alarm at end of sessions';
      case Language.french:
        return 'Alarme à la fin des sessions';
    }
  }

  String get filesEndPauseSound {
    switch (_current) {
      case Language.english:
        return 'Alarm at end of pauses';
      case Language.french:
        return 'Alarme à la fin des pauses';
    }
  }

  String get filesEndWorkingSound {
    switch (_current) {
      case Language.english:
        return 'Alarm at end of working';
      case Language.french:
        return 'Alarme à la fin des travaux';
    }
  }

  String get filesNoneSelected {
    switch (_current) {
      case Language.english:
        return 'No file selected';
      case Language.french:
        return 'Aucun fichier sélectionné';
    }
  }

  String get miscBackgroundColor {
    switch (_current) {
      case Language.english:
        return 'Background color';
      case Language.french:
        return 'Couleur de fond';
    }
  }

  String get miscBackgroundColorTooltip {
    switch (_current) {
      case Language.english:
        return 'The background color can be used as it is or set in a way '
            'that allows for easy removal (e.g., using a green screen). Please '
            'note that if you are using the web client, you can directly set '
            'the opacity to zero in the color picker to completely remove the '
            'background';
      case Language.french:
        return 'La couleur de fond peut être utilisée telle quelle ou '
            'configurée de manière à pouvoir être facilement supprimée (par '
            'exemple, en utilisant un écran vert). Veuillez noter que si vous '
            'utilisez le client web, vous pouvez directement régler l\'opacité '
            'à zéro dans le sélecteur de couleur pour supprimer complètement '
            'l\'arrière-plan';
    }
  }

  String get miscFont {
    switch (_current) {
      case Language.english:
        return 'Font';
      case Language.french:
        return 'Police d\'écriture';
    }
  }

  String get timerTextsTitle {
    switch (_current) {
      case Language.english:
        return 'Text to show on timer';
      case Language.french:
        return 'Texte à afficher sur le minuteur';
    }
  }

  String get timerTextsTitleTooltip {
    switch (_current) {
      case Language.english:
        return 'The following tags can be used to print some interesting\n'
            'information:\n'
            '    {currentSession} - the current session\n'
            '    {maxSessions} the maximum number of sessions\n'
            '    {timer} - the current value of the timer\n'
            '    {sessionDuration} - is the maximum time of the sessions\n'
            '    {pauseDuration} - is the maximum time of the pauses\n'
            '    \\n - adds a linebreak';
      case Language.french:
        return 'Les balises suivantes peuvent être utilisées pour afficher des '
            'informations intéressantes :\n'
            '    {currentSession} - la session en cours\n'
            '    {maxSessions} - le nombre maximum de sessions\n'
            '    {timer} - la valeur actuelle du minuteur\n'
            '    {sessionDuration} - la durée des sessions\n'
            '    {pauseDuration} - la durée des pauses\n'
            '    \\n - ajoute un saut de ligne';
    }
  }

  String get timerTextsIntroduction {
    switch (_current) {
      case Language.english:
        return 'Introduction text';
      case Language.french:
        return 'Texte d\'introduction';
    }
  }

  String get timerTextsSessions {
    switch (_current) {
      case Language.english:
        return 'Text during sessions';
      case Language.french:
        return 'Texte durant les sessions';
    }
  }

  String get timerTextsPauses {
    switch (_current) {
      case Language.english:
        return 'Text during pauses';
      case Language.french:
        return 'Texte durant les pauses';
    }
  }

  String get timerTextsTimerPauses {
    switch (_current) {
      case Language.english:
        return 'Text when timer is paused';
      case Language.french:
        return 'Texte lorsque le minuteur est mis en pause';
    }
  }

  String get timerTextsAllDone {
    switch (_current) {
      case Language.english:
        return 'Congratulating text when finished';
      case Language.french:
        return 'Texte de félicitation à la fin de la séance';
    }
  }

  String get timerTextsExport {
    switch (_current) {
      case Language.english:
        return 'Export texts to a file';
      case Language.french:
        return 'Exporter le text dans un fichier';
    }
  }

  String get timerTextsExportTooltip {
    switch (_current) {
      case Language.english:
        return 'If this option is selected, a file containing the printed '
            'message on the image will also be updated. This allows '
            'accessing the current state of the timer from outside '
            'this software. The file is located at: '
            '${appDirectory.path}/$textExportFilename';
      case Language.french:
        return 'Si cette option est sélectionnée, un fichier contenant le '
            'message imprimé sur l\'image sera également mis à jour. Cela '
            'permet d\'accéder à l\'état actuel du minuteur depuis l\'extérieur '
            'de ce logiciel. Le fichier se trouve à l\'addresse suivante : '
            '${appDirectory.path}/$textExportFilename';
    }
  }

  String get hallOfFameTitle {
    switch (_current) {
      case Language.english:
        return 'Hall of fame';
      case Language.french:
        return 'Tableau d\'honneur';
    }
  }

  String get hallOfFameTitleTooltip {
    switch (_current) {
      case Language.english:
        return 'The Hall of Fame requires you to be connected to Twitch.\n\n'
            'To personalize the messages sent to the chat, you can use '
            'the following tags:\n'
            '    {username} - the name of a user\n'
            '    {total} - the number of sessions previously completed\n'
            '    \\n - adds a linebreak';
      case Language.french:
        return 'The Tableau d\'honneur nécessite que vous soyez connecté à Twitch.\n\n'
            'Pour personnaliser les messages envoyés dans le chat, vous pouvez '
            'utiliser les balises suivantes :\n'
            '    {username} - le nom de l\'utilisateur\n'
            '    {total} - le nombre de sessions précédemment effectuées\n'
            '    \\n - ajoute un saut de ligne';
    }
  }

  String get hallOfFameUsage {
    switch (_current) {
      case Language.english:
        return 'Use hall of fame';
      case Language.french:
        return 'Utiliser le tableau d\'honneur';
    }
  }

  String get hallOfFameMustFollow {
    switch (_current) {
      case Language.english:
        return 'Must be a follower to register';
      case Language.french:
        return 'Doit suivre la chaine pour s\'inscrire';
    }
  }

  String get hallOfFameMustFollowTooltip {
    switch (_current) {
      case Language.english:
        return 'If this option is enabled, users need to be followers of your '
            'channel to be added to the current worker list. It is important '
            'to note that setting this option to false may result in a large '
            'number of users being added due to the presence of numerous '
            'bots on Twitch.\n\n'
            'The white and blacklists can be used to bypass the must be a '
            'follower requirement:\n'
            '    Whitelist - user will be added to the list regardless\n'
            '    Blacklist - user will not be added, even if they are '
            'follower. Typically, you would add your chatbots to the blacklist\n\n'
            'Please note that as a streamer, you are not considered a follower '
            'of your own channel. If you want your sessions to be counted, '
            'consider adding yourself to the whitelist';
      case Language.french:
        return 'Si cette option est activée, les utilisateurs doivent '
            'suivre votre chaîne pour être ajoutés à la liste de travail '
            'actuelle. Il est important de noter que désactiver cette option '
            'peut entraîner l\'ajout d\'un grand nombre d\'utilisateurs en '
            'raison de la présence de nombreux bots sur Twitch.\n\n'
            'Les listes blanche et noire peuvent être utilisées pour contourner '
            ' cette exigence :\n'
            '    Liste blanche - L\'utilisateur est ajouté en toutes circonstances\n'
            '    Liste noire - L\'utilisateur ne sera pas ajouté, même s\'ils '
            'suit la chaîne. En général, vous souhaiteriez ajouter vos chatbots '
            'à cette liste\n\n'
            'Veuillez noter qu\'en tant que streamer, vous ne suivez pas votre '
            'propre chaîne. Si vous souhaitez que vos sessions soient prises en '
            'compte, envisagez de vous ajouter à la liste blanche.';
    }
  }
}
