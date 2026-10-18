// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'LUMI Kids';

  @override
  String get lumiName => 'Lumi';

  @override
  String get commonClose => 'Close';

  @override
  String get commonBack => 'Back';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonError =>
      'Something went wrong. Please try again a bit later.';

  @override
  String get areaSpeech => 'Speech';

  @override
  String get areaLogic => 'Logic';

  @override
  String get areaMath => 'Numbers';

  @override
  String get areaLiteracy => 'Letters';

  @override
  String get areaMemory => 'Memory';

  @override
  String get areaEmotions => 'Feelings';

  @override
  String get areaSelfCare => 'Self-care';

  @override
  String get areaCreativity => 'Creativity';

  @override
  String get areaWorld => 'World around';

  @override
  String get areaMusic => 'Music';

  @override
  String get areaMovement => 'Movement';

  @override
  String get areaLanguages => 'Languages';

  @override
  String get programInfant => '0–1 year';

  @override
  String get programInfantHint => 'Activities together with an adult';

  @override
  String get programToddler => '1–2 years';

  @override
  String get programToddlerHint => 'Objects, animals, first words';

  @override
  String get programEarly => '2–3 years';

  @override
  String get programEarlyHint => 'Colours, shapes, sorting';

  @override
  String get programPreschool => '3–5 years';

  @override
  String get programPreschoolHint => 'Speech, logic, counting';

  @override
  String get programSchoolPrep => '5–7 years';

  @override
  String get programSchoolPrepHint => 'Getting ready for school';

  @override
  String get avatarBunny => 'Bunny';

  @override
  String get avatarBird => 'Bird';

  @override
  String get avatarBee => 'Bee';

  @override
  String get avatarPaw => 'Kitten';

  @override
  String get avatarFlower => 'Flower';

  @override
  String get avatarStar => 'Star';

  @override
  String get mapForAdults => 'For grown-ups';

  @override
  String get mapGreeting => 'Hi! I\'m Lumi.';

  @override
  String mapPlayingChild(String name) {
    return '$name is playing. Switch child';
  }

  @override
  String mapStarsLabel(int count) {
    return 'Stars: $count';
  }

  @override
  String mapIsland(String area) {
    return '$area island';
  }

  @override
  String mapIslandSoon(String area) {
    return '$area island, coming soon';
  }

  @override
  String get mapSoon => 'soon';

  @override
  String get mapParentLed =>
      'For babies under one, every activity is done together with an adult; the screen only suggests the idea.';

  @override
  String get mapAllDone => 'All activities done! New ones are coming soon.';

  @override
  String mapNext(String area) {
    return 'Next activity: $area';
  }

  @override
  String get areaToMap => 'To the map';

  @override
  String areaTaskLabel(int number, int stars) {
    return 'Task $number, stars $stars';
  }

  @override
  String get exerciseNotFound => 'Task not found';

  @override
  String get resultGreat => 'Well done!';

  @override
  String get resultPlayedTogether => 'Great playing together!';

  @override
  String get resultNext => 'Next';

  @override
  String get resultToIsland => 'Back to island';

  @override
  String get togetherTitle => 'Together with a grown-up';

  @override
  String get togetherHint =>
      'Put the phone down and play for real. Tap when you\'re done.';

  @override
  String get togetherDone => 'We did it!';

  @override
  String groupProgress(int placed, int total) {
    return '$placed of $total';
  }

  @override
  String get welcomeTitle => 'Hello!';

  @override
  String get welcomeText =>
      'Tell us a little about your child so Lumi can pick age-appropriate activities. Everything stays on this phone.';

  @override
  String get profileNameQuestion => 'What is your child\'s name?';

  @override
  String get profileNameHint => 'Name or nickname';

  @override
  String get profileNameHelper => 'No surname needed';

  @override
  String get profileAvatar => 'Icon';

  @override
  String get profileBirthYear => 'Year of birth';

  @override
  String get profileBirthMonth => 'Month of birth';

  @override
  String get profileMonthNote =>
      'No exact date needed: the month is enough to choose activities.';

  @override
  String get profileErrorName => 'Enter a name or nickname';

  @override
  String profileErrorNameTooLong(int max) {
    return 'The name is too long, up to $max letters';
  }

  @override
  String get profileErrorBirth => 'Choose the year and month of birth';

  @override
  String get profileErrorFuture => 'The date of birth can\'t be in the future';

  @override
  String get profileNew => 'New child';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileNotFound => 'Profile not found';

  @override
  String get profileDelete => 'Delete profile';

  @override
  String profileDeleteTitle(String name) {
    return 'Delete the profile \"$name\"?';
  }

  @override
  String get profileDeleteText =>
      'This child\'s profile and all progress will be deleted from the phone. This can\'t be undone.';

  @override
  String get switcherTitle => 'Who\'s playing?';

  @override
  String get switcherAddHint =>
      'You can add a child in the \"For grown-ups\" section.';

  @override
  String get gateTitle => 'For grown-ups';

  @override
  String gateQuestion(String a, String b) {
    return 'What is $a times $b?';
  }

  @override
  String get gateWrong => 'Not quite. Here\'s a new question.';

  @override
  String get number3 => 'three';

  @override
  String get number4 => 'four';

  @override
  String get number5 => 'five';

  @override
  String get number6 => 'six';

  @override
  String get number7 => 'seven';

  @override
  String get number8 => 'eight';

  @override
  String get number9 => 'nine';

  @override
  String get parentTitle => 'For grown-ups';

  @override
  String get parentChildren => 'Children';

  @override
  String get parentAddChild => 'Add a child';

  @override
  String get parentEditProfile => 'Edit profile';

  @override
  String parentProgressTitle(String name) {
    return 'Progress: $name';
  }

  @override
  String parentProgram(String program) {
    return 'Programme: $program';
  }

  @override
  String get parentCompleted => 'activities in total';

  @override
  String get parentLastWeek => 'in 7 days';

  @override
  String get parentByArea => 'By area';

  @override
  String get parentByAreaNote =>
      'These are observations from activities in the app, not an assessment of development.';

  @override
  String parentTriedOf(int tried, int total) {
    return '$tried of $total';
  }

  @override
  String get statusNotTried => 'Not tried yet';

  @override
  String get statusTrying => 'Still trying, help with a hint';

  @override
  String get statusConfident => 'Usually manages alone';

  @override
  String get parentTryTogether => 'Try together';

  @override
  String get parentRecent => 'Recent activities';

  @override
  String get parentHistoryEmpty =>
      'Nothing yet. Activities your child completes will appear here.';

  @override
  String get parentTaskGone => 'This activity is no longer available';

  @override
  String get parentWithHints => ', with hints';

  @override
  String get parentContent => 'Activities';

  @override
  String parentContentNow(String source) {
    return 'Now: $source';
  }

  @override
  String contentDownloaded(int version) {
    return 'pack #$version from the server';
  }

  @override
  String contentBundled(int version) {
    return 'built-in pack (version $version)';
  }

  @override
  String get parentCheckUpdates => 'Check for new activities';

  @override
  String get updateUpdated =>
      'New activities downloaded. They will appear the next time you open the app.';

  @override
  String get updateUpToDate => 'No new activities yet.';

  @override
  String get updateNotConfigured =>
      'This build has no server address: built-in activities are used.';

  @override
  String get updateOffline =>
      'Couldn\'t reach the server. Activities work without the internet too.';

  @override
  String get updateRejected =>
      'The pack from the server was damaged and wasn\'t saved. Please try later.';

  @override
  String get parentLanguage => 'Language';

  @override
  String get parentLanguageNote =>
      'Activities are in Russian for now: translations will appear after native-speaker review.';

  @override
  String get parentData => 'Data';

  @override
  String get parentPrivacy =>
      'Profiles and progress are stored only on this phone and are never sent anywhere. We don\'t ask for photos, voice, surname or exact date of birth. The app has no ads and no chats. When checking for new activities, the app only downloads the pack and sends nothing about your child.';

  @override
  String get parentDeleteAll => 'Delete all data';

  @override
  String get parentDeleteAllTitle => 'Delete all data?';

  @override
  String get parentDeleteAllText =>
      'All child profiles, progress and settings will be deleted from the phone. This can\'t be undone.';

  @override
  String get parentDeleteAllConfirm => 'Delete everything';

  @override
  String get month1 => 'Jan';

  @override
  String get month2 => 'Feb';

  @override
  String get month3 => 'Mar';

  @override
  String get month4 => 'Apr';

  @override
  String get month5 => 'May';

  @override
  String get month6 => 'Jun';

  @override
  String get month7 => 'Jul';

  @override
  String get month8 => 'Aug';

  @override
  String get month9 => 'Sep';

  @override
  String get month10 => 'Oct';

  @override
  String get month11 => 'Nov';

  @override
  String get month12 => 'Dec';
}
