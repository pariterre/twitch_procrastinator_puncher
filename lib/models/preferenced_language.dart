import 'package:twitch_procastinator_puncher/models/config.dart';
import 'package:twitch_procastinator_puncher/models/preferenced_element.dart';

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

  static Future<PreferencedLanguage> deserialize(map,
          [int defaultValue = 0]) async =>
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

  String get titleDescriptionDesktop {
    switch (_current) {
      case Language.english:
        return 'Welcome to the Procrastination Hunter!\n'
            'This software can be used as is to help you punch the procrastination. '
            'It\'s also possible to connect it to Twitch for use during your '
            'broadcasts. In this case, to import it into your streaming '
            'platform, you can capture the window. Alternatively, you can use '
            'the web version at the following address: ';
      case Language.french:
        return 'Bienvenue au Chasseur de Procrastination!\n'
            'Ce logiciel peut être utilisé tel quel pour vous aider à chasser la '
            'procrastination. Il est également possible de le connecter à Twitch '
            'pour être utilisé lors de vos diffusions. Dans ce cas, pour '
            'l\'importer dans votre plateforme de diffusion, vous pouvez capturer '
            'la fenêtre. Alternativement, vous pouvez utiliser la version web à '
            'l\'adresse suivante : ';
    }
  }

  String get titleDescriptionWeb {
    switch (_current) {
      case Language.english:
        return 'Welcome to the Procrastination Puncher!\n'
            'This software can be used as is to help you punch the procrastination. '
            'It\'s also possible to connect it to Twitch for use during your '
            'broadcasts. In this case, to import it into your streaming platform, '
            'you can simply open a web browser and import this web page.';
      case Language.french:
        return 'Bienvenue au Chasseur de Procrastination!\n'
            'Ce logiciel peut être utilisé tel quel pour vous aider à chasser la '
            'procrastination. Il est également possible de le connecter à Twitch '
            'pour être utilisé lors de vos diffusions. Dans ce cas, pour '
            'l\'importer dans votre plateforme de diffusion, vous pouvez '
            'simplement ouvrir un navigateur web et y importer cette page web.';
    }
  }

  String get controllerTitle {
    switch (_current) {
      case Language.english:
        return 'Timer controller';
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

  String get controllerReconnectTwitchConfirm {
    switch (_current) {
      case Language.english:
        return 'Reconnecting to Twitch';
      case Language.french:
        return 'Reconnexion à Twitch';
    }
  }

  String get controllerReconnectTwitchContent {
    switch (_current) {
      case Language.english:
        return 'Are you sure you want to reconnect to Twitch?';
      case Language.french:
        return 'Êtes-vous certain de vouloir reconnecter à Twitch?';
    }
  }

  String get controllerConfigurationTitle {
    switch (_current) {
      case Language.english:
        return 'Timer configuration';
      case Language.french:
        return 'Configuration du minuteur';
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

  String get controllerSessionIndividually {
    switch (_current) {
      case Language.english:
        return 'Manager sessions individually';
      case Language.french:
        return 'Gérer les sessions individuellement';
    }
  }

  String controllerSessionIndexed(int index) {
    switch (_current) {
      case Language.english:
        return 'Session $index';
      case Language.french:
        return 'Session $index';
    }
  }

  String get controllerSessionsDuration {
    switch (_current) {
      case Language.english:
        return 'Sessions duration (mm:ss)';
      case Language.french:
        return 'Durée des séances (mm:ss)';
    }
  }

  String get controllerSessionDuration {
    switch (_current) {
      case Language.english:
        return 'Session duration (mm:ss)';
      case Language.french:
        return 'Durée de la séance (mm:ss)';
    }
  }

  String get controllerPausesDuration {
    switch (_current) {
      case Language.english:
        return 'Pauses duration (mm:ss)';
      case Language.french:
        return 'Durée des pauses (mm:ss)';
    }
  }

  String get controllerPauseDuration {
    switch (_current) {
      case Language.english:
        return 'Pause duration (mm:ss)';
      case Language.french:
        return 'Durée de la pause (mm:ss)';
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

  String get filesEndImage {
    switch (_current) {
      case Language.english:
        return 'Image at the end of sessions';
      case Language.french:
        return 'Image à la fin des séances';
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

  String get miscTitle {
    switch (_current) {
      case Language.english:
        return 'All field configuration';
      case Language.french:
        return 'Configuration de tous les champs';
    }
  }

  String get supportingMeTitle {
    switch (_current) {
      case Language.english:
        return 'Buy me a coffee';
      case Language.french:
        return 'M\'offrir un café';
    }
  }

  String get supportingMeText {
    switch (_current) {
      case Language.english:
        return 'If you like this software, consider buying me a coffee. It will '
            'help me continue to develop this software and others.';
      case Language.french:
        return 'Si vous aimez ce logiciel, considérez m\'acheter un café. Cela '
            'm\'aidera à continuer de développer ce logiciel et d\'autres.';
    }
  }

  String get buyMeACoffeeDialogTitle {
    switch (_current) {
      case Language.english:
        return 'Buy me a coffee';
      case Language.french:
        return 'M\'offrir un café';
    }
  }

  String get buyMeACoffeeDialogContent {
    switch (_current) {
      case Language.english:
        return 'Today is my birthday! If you like this software, I\'d be '
            'eternally grateful if you were to consider buying me a coffee.\n'
            'It will help me continue to develop this software and others.';
      case Language.french:
        return 'Aujourd\'hui est mon anniversaire! Si vous aimez ce logiciel, '
            'je vous serais éternellement reconnaissant si vous envisagiez de '
            'm\'acheter un café.\n'
            'Cela m\'aidera à continuer de développer ce '
            'logiciel et d\'autres.';
    }
  }

  String get buyMeACoffeeDialogNo {
    switch (_current) {
      case Language.english:
        return 'No, what you a doing is not so great...';
      case Language.french:
        return 'Non, ce que tu fais n\'est pas si génial...';
    }
  }

  String get buyMeACoffeeDialogYes {
    switch (_current) {
      case Language.english:
        return 'Yes, you are awesome!';
      case Language.french:
        return 'Oui, tu es génial!';
    }
  }

  String get miscExportButton {
    switch (_current) {
      case Language.english:
        return 'Export configuration';
      case Language.french:
        return 'Exporter la\nconfiguration';
    }
  }

  String get miscImportButton {
    switch (_current) {
      case Language.english:
        return 'Import configuration';
      case Language.french:
        return 'Importer la\nconfiguration';
    }
  }

  String get miscImportAreYouSureTitle {
    switch (_current) {
      case Language.english:
        return 'Confirm importing';
      case Language.french:
        return 'Confimer l\'importation';
    }
  }

  String get micsImportAreYouSureContent {
    switch (_current) {
      case Language.english:
        return 'Are you sure you want to import data? This action will override '
            'current data and is irreversible';
      case Language.french:
        return 'Êtes-vous certain de vouloir import les données? Ceci excrasera '
            'les données existantes et est irréversible. \n\n'
            'Notez cependant que pour des raisons de sécurités, les fichiers '
            'sources (tels image et son) doivent être réimportées à la main';
    }
  }

  String get miscResetButton {
    switch (_current) {
      case Language.english:
        return 'Reset configuration';
      case Language.french:
        return 'Réinitialiser la configuration';
    }
  }

  String get miscResetConfirmTitle {
    switch (_current) {
      case Language.english:
        return 'Resetting configuration';
      case Language.french:
        return 'Réinitialiation de la configuration';
    }
  }

  String get miscResetConfirm {
    switch (_current) {
      case Language.english:
        return 'Are you sure you wat to reset the configuration to their '
            'original values?';
      case Language.french:
        return 'Êtes-vous certains de vouloir réinitialiser la configuration '
            'aux valeurs d\'origine?';
    }
  }

  String get miscCancel {
    switch (_current) {
      case Language.english:
        return 'Cancel';
      case Language.french:
        return 'Annuler';
    }
  }

  String get miscConfirm {
    switch (_current) {
      case Language.english:
        return 'Confirm';
      case Language.french:
        return 'Confirmer';
    }
  }

  String get miscQuitTitle {
    switch (_current) {
      case Language.english:
        return 'Exit';
      case Language.french:
        return 'Quitter';
    }
  }

  String get miscQuitContent {
    switch (_current) {
      case Language.english:
        return 'Are you sure you want to quit the Procrastinator Puncher?';
      case Language.french:
        return 'Êtes-vous sûr de vouloir quitter le Chasseur de Procrastination?';
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
            '    {session} - the current session\n'
            '    {nbSessions} the maximum number of sessions\n'
            '    {timer} - the current value of the timer\n'
            '    {sessionTime} - is the maximum time of the sessions\n'
            '    {pauseTime} - is the maximum time of the pauses\n'
            '    {done} - is the number of sessions collectively done\n'
            '    {doneToday} - is the number of sessions collectively done today\n'
            '    \\n - adds a linebreak';
      case Language.french:
        return 'Les balises suivantes peuvent être utilisées pour afficher des '
            'informations intéressantes :\n'
            '    {session} - la session en cours\n'
            '    {nbSessions} - le nombre maximum de sessions\n'
            '    {timer} - la valeur actuelle du minuteur\n'
            '    {sessionTime} - la durée des sessions\n'
            '    {pauseTime} - la durée des pauses\n'
            '    {done} - le nombre de sessions collectivement réalisées\n'
            '    {doneToday} - le nombre de sessions collectivement réalisées aujourd\'hui\n'
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
        return 'Exporter le texte dans un fichier';
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

  String get rewardRedemptionTitle {
    switch (_current) {
      case Language.english:
        return 'Reward redemption';
      case Language.french:
        return 'Réclamation de récompenses';
    }
  }

  String get rewardRedemptionTitleTooltip {
    switch (_current) {
      case Language.english:
        return 'The reward redemption of the followers requires you to be connected to Twitch.\n\n'
            'It is possible to setup an automatic answer from the bot to any redemption\n'
            'using the text field "Chatbot answer". To personalize the messages\n'
            'sent to the chat, you can use the following tags:\n'
            '    {title} - the current name of the redemption\n'
            '    {username} - the name of the user who redempted the reward\n'
            '    {cost} - the cost of the reward\n'
            '    {message} - the message from the user in the redemption';
      case Language.french:
        return 'La réclamation de récompenses nécessite que vous soyez connecté à Twitch.\n\n'
            'Il est possible de configurer une réponse automatique du chatbot à une\n'
            'réclamation en utilisant le champ de texte "Réponse du chatbot".\n'
            'Pour personnaliser les messages envoyés dans le chat, vous pouvez\n'
            'utiliser les balises suivantes :\n'
            '    {title} - le nom de la réclamation en cours\n'
            '    {username} - le nom de l\'utilisateur ayant fait la réclamation\n'
            '    {cost} - le coût de la réclamation\n'
            '    {message} - le message de l\'utilisateur dans la réclamation';
    }
  }

  String get rewardRedemptionAddButton {
    switch (_current) {
      case Language.english:
        return 'Add a new reward redemption';
      case Language.french:
        return 'Ajouter une réclamation de récompense';
    }
  }

  String get rewardRedemptionChatbotAnswer {
    switch (_current) {
      case Language.english:
        return 'Chatbot answer. ';
      case Language.french:
        return 'Réponse du chatbot';
    }
  }

  String get rewardRedemptionNone {
    switch (_current) {
      case Language.english:
        return 'Select a reward';
      case Language.french:
        return 'Sélectionner une récompense';
    }
  }

  String get rewardRedemptionAddTime {
    switch (_current) {
      case Language.english:
        return 'Add time to the timer';
      case Language.french:
        return 'Ajouter au chronomètre';
    }
  }

  String get rewardRedemptionNextPauseIsLonger {
    switch (_current) {
      case Language.english:
        return 'Longer pause';
      case Language.french:
        return 'Pause plus longue';
    }
  }

  String get rewardRedemptionNextSessionIsLonger {
    switch (_current) {
      case Language.english:
        return 'Longer session';
      case Language.french:
        return 'Séance plus longue';
    }
  }

  String get rewardRedemptionLabel {
    switch (_current) {
      case Language.english:
        return 'Write the exact name of the reward redemption';
      case Language.french:
        return 'Écrivez le nom exact de la réclamation de récompense';
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

  String get hallOfFameExport {
    switch (_current) {
      case Language.english:
        return 'Export participant\nlist';
      case Language.french:
        return 'Exporter une liste\nde participants';
    }
  }

  String get hallOfFameImport {
    switch (_current) {
      case Language.english:
        return 'Import participant\nlist';
      case Language.french:
        return 'Importer une liste\nde participants';
    }
  }

  String get hallOfFameImportAreYouSureTitle {
    switch (_current) {
      case Language.english:
        return 'Confirm importing';
      case Language.french:
        return 'Confimer l\'importation';
    }
  }

  String get hallOfFameImportAreYouSureContent {
    switch (_current) {
      case Language.english:
        return 'Are you sure you want to import data? This action will override '
            'current data and is irreversible';
      case Language.french:
        return 'Êtes-vous certain de vouloir import les données? Ceci excrasera '
            'les données existantes et est irréversible';
    }
  }

  String get hallOfFameTitleTooltip {
    switch (_current) {
      case Language.english:
        return 'The Hall of Fame requires you to be connected to Twitch.';
      case Language.french:
        return 'Le Tableau d\'honneur nécessite que vous soyez connecté à Twitch.';
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

  String get hallOfFameWhiteListed {
    switch (_current) {
      case Language.english:
        return 'Whitelisted users (semicolon separated)';
      case Language.french:
        return 'Utilisateurs sur la liste blanche (séparés par un point-virgule)';
    }
  }

  String get hallOfFameBlackListed {
    switch (_current) {
      case Language.english:
        return 'Blacklisted users (semicolon separated)';
      case Language.french:
        return 'Utilisateurs sur la liste noire (séparés par un point-virgule)';
    }
  }

  String get hallOfFameBackgroundColor {
    switch (_current) {
      case Language.english:
        return 'Background color of the hall of fame';
      case Language.french:
        return 'Couleur de fond du tableau d\'honneur';
    }
  }

  String get hallOfFameTextColor {
    switch (_current) {
      case Language.english:
        return 'Text color of the hall of fame';
      case Language.french:
        return 'Couleur du texte du tableau d\'honneur';
    }
  }

  String get hallOfFameScollingSpeed {
    switch (_current) {
      case Language.english:
        return 'Scroll velocity';
      case Language.french:
        return 'Vitesse de défilement';
    }
  }

  String get hallOfFameTextTitleMain {
    switch (_current) {
      case Language.english:
        return 'Main title';
      case Language.french:
        return 'Titre du tableau';
    }
  }

  String get hallOfFameTextTitleViewers {
    switch (_current) {
      case Language.english:
        return 'Viewers names title';
      case Language.french:
        return 'Titre des utilisateurs';
    }
  }

  String get hallOfFameTextTitleToday {
    switch (_current) {
      case Language.english:
        return 'Today title';
      case Language.french:
        return 'Titre aujourd\'hui';
    }
  }

  String get hallOfFameTextTitleInAll {
    switch (_current) {
      case Language.english:
        return 'All time title';
      case Language.french:
        return 'Titre en tout';
    }
  }

  String get hallOfFameTextTitleGrandTotal {
    switch (_current) {
      case Language.english:
        return 'Grand total';
      case Language.french:
        return 'Grand total';
    }
  }

  String get chatTitle {
    switch (_current) {
      case Language.english:
        return 'Chatbot messages';
      case Language.french:
        return 'Messages de clavardage automatiques';
    }
  }

  String get chatTitleTooltip {
    switch (_current) {
      case Language.english:
        return 'These are all the message that the chatbot will automatically send '
            'when certain events occur. This option necessitate that you are '
            'connected to Twitch.\n\n'
            'To personalize the messages sent to the chat, you can use '
            'the following tags:\n'
            '    {session} - the current session\n'
            '    {nbSessions} the maximum number of sessions\n'
            '    {timer} - the current value of the timer\n'
            '    {sessionTime} - is the maximum time of the sessions\n'
            '    {pauseTime} - is the maximum time of the pauses\n'
            '    {done} - is the number of sessions collectively done\n'
            '    {doneToday} - is the number of sessions collectively done today\n'
            '    *{username} - the name of a user\n'
            '    *{userDone} - the number of completed sessions by the user\n'
            '    *{userDoneToday} - the number of sessions completed today by the user\n'
            '* Only for the fields marked with a star';
      case Language.french:
        return 'Messages automatiquement envoyés par le chatbot lorsque certains '
            'événements ont lieus. Cette option nécessite d\'être connecté '
            'à Twitch.\n\n'
            'Pour personnaliser les messages envoyés dans le chat, vous pouvez '
            'utiliser les balises suivantes :\n'
            '    {session} - la session en cours\n'
            '    {nbSessions} - le nombre maximum de sessions\n'
            '    {timer} - la valeur actuelle du minuteur\n'
            '    {sessionTime} - la durée des sessions\n'
            '    {pauseTime} - la durée des pauses\n'
            '    {done} - le nombre de sessions collectivement réalisées\n'
            '    {doneToday} - le nombre de sessions collectivement réalisées aujourd\'hui\n'
            '    *{username} - le nom de l\'utilisateur\n'
            '    *{userDone} - le nombre de sessions réalisées par l\'utilisateur\n'
            '    *{userDoneToday} - le nombre de sessions réalisées par l\'utilisateur aujourd\'hui\n'
            '* Seulement pour les champs marqués d\'une étoile';
    }
  }

  String get chatTimerHasStarted {
    switch (_current) {
      case Language.english:
        return 'Timer has started';
      case Language.french:
        return 'Le minuteur a commencé';
    }
  }

  String get chatTimerSessionHasEnded {
    switch (_current) {
      case Language.english:
        return 'A session has ended';
      case Language.french:
        return 'Une session s\'est terminée';
    }
  }

  String get chatTimerPauseHasEnded {
    switch (_current) {
      case Language.english:
        return 'A pause has ended';
      case Language.french:
        return 'Une pause s\'est terminée';
    }
  }

  String get chatTimerWorkingHasEnded {
    switch (_current) {
      case Language.english:
        return 'Working has ended';
      case Language.french:
        return 'Le travail s\'est terminé';
    }
  }

  String get chatNewcomerGreetings {
    switch (_current) {
      case Language.english:
        return '* Newcomer greetings';
      case Language.french:
        return '* Bienvenue aux nouveaux';
    }
  }

  String get chatUserHasConnected {
    switch (_current) {
      case Language.english:
        return '* User has connected';
      case Language.french:
        return '* Connexion d\'un utilisateur';
    }
  }

  String get chatbotTitle {
    switch (_current) {
      case Language.english:
        return 'Chatbot reponses';
      case Language.french:
        return 'Réponses automatiques';
    }
  }

  String get chatbotTitleTooltip {
    switch (_current) {
      case Language.english:
        return 'These are all the message that the chatbot will automatically respond '
            'to if a certain command is received. Typically, starting with a "!".'
            'This option necessitate that you are connected to Twitch.\n\n'
            'To personalize the messages sent to the chat, you can use '
            'the following tags:\n'
            '    {session} - the current session\n'
            '    {nbSessions} the maximum number of sessions\n'
            '    {timer} - the current value of the timer\n'
            '    {sessionTime} - is the maximum time of the sessions\n'
            '    {pauseTime} - is the maximum time of the pauses\n'
            '    {done} - is the number of sessions collectively done\n'
            '    {doneToday} - is the number of sessions collectively done today';
      case Language.french:
        return 'Réponses automatiquement envoyées par le chatbot lorsque qu\'une '
            'commande spécifique a lieue. Cette option nécessite d\'être connecté '
            'à Twitch.\n\n'
            'Pour personnaliser les messages envoyés dans le chat, vous pouvez '
            'utiliser les balises suivantes :\n'
            '    {session} - la session en cours\n'
            '    {nbSessions} - le nombre maximum de sessions\n'
            '    {timer} - la valeur actuelle du minuteur\n'
            '    {sessionTime} - la durée des sessions\n'
            '    {pauseTime} - la durée des pauses\n'
            '    {done} - le nombre de sessions collectivement réalisées\n'
            '    {doneToday} - le nombre de sessions collectivement réalisées aujourd\'hui';
    }
  }

  String get chatbotAddNew {
    switch (_current) {
      case Language.english:
        return 'Add a new chatbot response';
      case Language.french:
        return 'Ajouter une nouvelle réponse automatique';
    }
  }

  String get chatbotLabel {
    switch (_current) {
      case Language.english:
        return 'Write the command the bot should respond to';
      case Language.french:
        return 'Écrivez la commande à laquelle le bot devrait répondre';
    }
  }

  String get chatbotAnswer {
    switch (_current) {
      case Language.english:
        return 'Chatbot answer';
      case Language.french:
        return 'Réponse du chatbot';
    }
  }
}
