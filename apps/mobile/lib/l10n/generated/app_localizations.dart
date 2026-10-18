import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('uz'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'LUMI Kids'**
  String get appTitle;

  /// No description provided for @lumiName.
  ///
  /// In ru, this message translates to:
  /// **'Люми'**
  String get lumiName;

  /// No description provided for @commonClose.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть'**
  String get commonClose;

  /// No description provided for @commonBack.
  ///
  /// In ru, this message translates to:
  /// **'Назад'**
  String get commonBack;

  /// No description provided for @commonCancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get commonDelete;

  /// No description provided for @commonError.
  ///
  /// In ru, this message translates to:
  /// **'Что-то пошло не так. Попробуй ещё раз чуть позже.'**
  String get commonError;

  /// No description provided for @areaSpeech.
  ///
  /// In ru, this message translates to:
  /// **'Речь'**
  String get areaSpeech;

  /// No description provided for @areaLogic.
  ///
  /// In ru, this message translates to:
  /// **'Логика'**
  String get areaLogic;

  /// No description provided for @areaMath.
  ///
  /// In ru, this message translates to:
  /// **'Числа'**
  String get areaMath;

  /// No description provided for @areaLiteracy.
  ///
  /// In ru, this message translates to:
  /// **'Буквы'**
  String get areaLiteracy;

  /// No description provided for @areaMemory.
  ///
  /// In ru, this message translates to:
  /// **'Память'**
  String get areaMemory;

  /// No description provided for @areaEmotions.
  ///
  /// In ru, this message translates to:
  /// **'Эмоции'**
  String get areaEmotions;

  /// No description provided for @areaSelfCare.
  ///
  /// In ru, this message translates to:
  /// **'Сам себе'**
  String get areaSelfCare;

  /// No description provided for @areaCreativity.
  ///
  /// In ru, this message translates to:
  /// **'Творчество'**
  String get areaCreativity;

  /// No description provided for @areaWorld.
  ///
  /// In ru, this message translates to:
  /// **'Мир вокруг'**
  String get areaWorld;

  /// No description provided for @areaMusic.
  ///
  /// In ru, this message translates to:
  /// **'Музыка'**
  String get areaMusic;

  /// No description provided for @areaMovement.
  ///
  /// In ru, this message translates to:
  /// **'Движение'**
  String get areaMovement;

  /// No description provided for @areaLanguages.
  ///
  /// In ru, this message translates to:
  /// **'Языки'**
  String get areaLanguages;

  /// No description provided for @programInfant.
  ///
  /// In ru, this message translates to:
  /// **'0–1 год'**
  String get programInfant;

  /// No description provided for @programInfantHint.
  ///
  /// In ru, this message translates to:
  /// **'Занятия вместе со взрослым'**
  String get programInfantHint;

  /// No description provided for @programToddler.
  ///
  /// In ru, this message translates to:
  /// **'1–2 года'**
  String get programToddler;

  /// No description provided for @programToddlerHint.
  ///
  /// In ru, this message translates to:
  /// **'Предметы, животные, первые слова'**
  String get programToddlerHint;

  /// No description provided for @programEarly.
  ///
  /// In ru, this message translates to:
  /// **'2–3 года'**
  String get programEarly;

  /// No description provided for @programEarlyHint.
  ///
  /// In ru, this message translates to:
  /// **'Цвета, формы, сортировка'**
  String get programEarlyHint;

  /// No description provided for @programPreschool.
  ///
  /// In ru, this message translates to:
  /// **'3–5 лет'**
  String get programPreschool;

  /// No description provided for @programPreschoolHint.
  ///
  /// In ru, this message translates to:
  /// **'Речь, логика, счёт'**
  String get programPreschoolHint;

  /// No description provided for @programSchoolPrep.
  ///
  /// In ru, this message translates to:
  /// **'5–7 лет'**
  String get programSchoolPrep;

  /// No description provided for @programSchoolPrepHint.
  ///
  /// In ru, this message translates to:
  /// **'Подготовка к школе'**
  String get programSchoolPrepHint;

  /// No description provided for @avatarBunny.
  ///
  /// In ru, this message translates to:
  /// **'Зайчик'**
  String get avatarBunny;

  /// No description provided for @avatarBird.
  ///
  /// In ru, this message translates to:
  /// **'Птичка'**
  String get avatarBird;

  /// No description provided for @avatarBee.
  ///
  /// In ru, this message translates to:
  /// **'Пчёлка'**
  String get avatarBee;

  /// No description provided for @avatarPaw.
  ///
  /// In ru, this message translates to:
  /// **'Котёнок'**
  String get avatarPaw;

  /// No description provided for @avatarFlower.
  ///
  /// In ru, this message translates to:
  /// **'Цветок'**
  String get avatarFlower;

  /// No description provided for @avatarStar.
  ///
  /// In ru, this message translates to:
  /// **'Звёздочка'**
  String get avatarStar;

  /// No description provided for @mapForAdults.
  ///
  /// In ru, this message translates to:
  /// **'Для взрослых'**
  String get mapForAdults;

  /// No description provided for @mapGreeting.
  ///
  /// In ru, this message translates to:
  /// **'Привет! Я Люми.'**
  String get mapGreeting;

  /// No description provided for @mapPlayingChild.
  ///
  /// In ru, this message translates to:
  /// **'Играет {name}. Сменить ребёнка'**
  String mapPlayingChild(String name);

  /// No description provided for @mapStarsLabel.
  ///
  /// In ru, this message translates to:
  /// **'Звёзд: {count}'**
  String mapStarsLabel(int count);

  /// No description provided for @mapIsland.
  ///
  /// In ru, this message translates to:
  /// **'Остров {area}'**
  String mapIsland(String area);

  /// No description provided for @mapIslandSoon.
  ///
  /// In ru, this message translates to:
  /// **'Остров {area}, скоро'**
  String mapIslandSoon(String area);

  /// No description provided for @mapSoon.
  ///
  /// In ru, this message translates to:
  /// **'скоро'**
  String get mapSoon;

  /// No description provided for @mapParentLed.
  ///
  /// In ru, this message translates to:
  /// **'Для малышей до года все занятия проходят вместе со взрослым, экран только подсказывает идею.'**
  String get mapParentLed;

  /// No description provided for @mapAllDone.
  ///
  /// In ru, this message translates to:
  /// **'Все занятия пройдены! Скоро появятся новые.'**
  String get mapAllDone;

  /// No description provided for @mapNext.
  ///
  /// In ru, this message translates to:
  /// **'Следующее занятие: {area}'**
  String mapNext(String area);

  /// No description provided for @areaToMap.
  ///
  /// In ru, this message translates to:
  /// **'На карту'**
  String get areaToMap;

  /// No description provided for @areaTaskLabel.
  ///
  /// In ru, this message translates to:
  /// **'Задание {number}, звёзд {stars}'**
  String areaTaskLabel(int number, int stars);

  /// No description provided for @exerciseNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Задание не найдено'**
  String get exerciseNotFound;

  /// No description provided for @resultGreat.
  ///
  /// In ru, this message translates to:
  /// **'Молодец!'**
  String get resultGreat;

  /// No description provided for @resultPlayedTogether.
  ///
  /// In ru, this message translates to:
  /// **'Здорово поиграли!'**
  String get resultPlayedTogether;

  /// No description provided for @resultNext.
  ///
  /// In ru, this message translates to:
  /// **'Дальше'**
  String get resultNext;

  /// No description provided for @resultToIsland.
  ///
  /// In ru, this message translates to:
  /// **'К острову'**
  String get resultToIsland;

  /// No description provided for @togetherTitle.
  ///
  /// In ru, this message translates to:
  /// **'Вместе со взрослым'**
  String get togetherTitle;

  /// No description provided for @togetherHint.
  ///
  /// In ru, this message translates to:
  /// **'Отложите телефон и играйте вживую. Отметьте, когда закончите.'**
  String get togetherHint;

  /// No description provided for @togetherDone.
  ///
  /// In ru, this message translates to:
  /// **'Мы сделали!'**
  String get togetherDone;

  /// No description provided for @groupProgress.
  ///
  /// In ru, this message translates to:
  /// **'{placed} из {total}'**
  String groupProgress(int placed, int total);

  /// No description provided for @welcomeTitle.
  ///
  /// In ru, this message translates to:
  /// **'Здравствуйте!'**
  String get welcomeTitle;

  /// No description provided for @welcomeText.
  ///
  /// In ru, this message translates to:
  /// **'Расскажите немного о ребёнке, чтобы Люми подобрал занятия по возрасту. Всё хранится только на этом телефоне.'**
  String get welcomeText;

  /// No description provided for @profileNameQuestion.
  ///
  /// In ru, this message translates to:
  /// **'Как зовут ребёнка?'**
  String get profileNameQuestion;

  /// No description provided for @profileNameHint.
  ///
  /// In ru, this message translates to:
  /// **'Имя или прозвище'**
  String get profileNameHint;

  /// No description provided for @profileNameHelper.
  ///
  /// In ru, this message translates to:
  /// **'Фамилия не нужна'**
  String get profileNameHelper;

  /// No description provided for @profileAvatar.
  ///
  /// In ru, this message translates to:
  /// **'Значок'**
  String get profileAvatar;

  /// No description provided for @profileBirthYear.
  ///
  /// In ru, this message translates to:
  /// **'Год рождения'**
  String get profileBirthYear;

  /// No description provided for @profileBirthMonth.
  ///
  /// In ru, this message translates to:
  /// **'Месяц рождения'**
  String get profileBirthMonth;

  /// No description provided for @profileMonthNote.
  ///
  /// In ru, this message translates to:
  /// **'Точная дата не нужна: месяца хватает, чтобы подобрать занятия.'**
  String get profileMonthNote;

  /// No description provided for @profileErrorName.
  ///
  /// In ru, this message translates to:
  /// **'Введите имя или прозвище'**
  String get profileErrorName;

  /// No description provided for @profileErrorNameTooLong.
  ///
  /// In ru, this message translates to:
  /// **'Имя слишком длинное, до {max} букв'**
  String profileErrorNameTooLong(int max);

  /// No description provided for @profileErrorBirth.
  ///
  /// In ru, this message translates to:
  /// **'Выберите год и месяц рождения'**
  String get profileErrorBirth;

  /// No description provided for @profileErrorFuture.
  ///
  /// In ru, this message translates to:
  /// **'Дата рождения не может быть в будущем'**
  String get profileErrorFuture;

  /// No description provided for @profileNew.
  ///
  /// In ru, this message translates to:
  /// **'Новый ребёнок'**
  String get profileNew;

  /// No description provided for @profileTitle.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get profileTitle;

  /// No description provided for @profileNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Профиль не найден'**
  String get profileNotFound;

  /// No description provided for @profileDelete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить профиль'**
  String get profileDelete;

  /// No description provided for @profileDeleteTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить профиль «{name}»?'**
  String profileDeleteTitle(String name);

  /// No description provided for @profileDeleteText.
  ///
  /// In ru, this message translates to:
  /// **'Профиль и весь прогресс этого ребёнка будут удалены с телефона. Вернуть их не получится.'**
  String get profileDeleteText;

  /// No description provided for @switcherTitle.
  ///
  /// In ru, this message translates to:
  /// **'Кто играет?'**
  String get switcherTitle;

  /// No description provided for @switcherAddHint.
  ///
  /// In ru, this message translates to:
  /// **'Добавить ребёнка можно в разделе «Для взрослых».'**
  String get switcherAddHint;

  /// No description provided for @gateTitle.
  ///
  /// In ru, this message translates to:
  /// **'Для взрослых'**
  String get gateTitle;

  /// No description provided for @gateQuestion.
  ///
  /// In ru, this message translates to:
  /// **'Сколько будет {a} умножить на {b}?'**
  String gateQuestion(String a, String b);

  /// No description provided for @gateWrong.
  ///
  /// In ru, this message translates to:
  /// **'Неверно. Вот новый вопрос.'**
  String get gateWrong;

  /// No description provided for @number3.
  ///
  /// In ru, this message translates to:
  /// **'три'**
  String get number3;

  /// No description provided for @number4.
  ///
  /// In ru, this message translates to:
  /// **'четыре'**
  String get number4;

  /// No description provided for @number5.
  ///
  /// In ru, this message translates to:
  /// **'пять'**
  String get number5;

  /// No description provided for @number6.
  ///
  /// In ru, this message translates to:
  /// **'шесть'**
  String get number6;

  /// No description provided for @number7.
  ///
  /// In ru, this message translates to:
  /// **'семь'**
  String get number7;

  /// No description provided for @number8.
  ///
  /// In ru, this message translates to:
  /// **'восемь'**
  String get number8;

  /// No description provided for @number9.
  ///
  /// In ru, this message translates to:
  /// **'девять'**
  String get number9;

  /// No description provided for @parentTitle.
  ///
  /// In ru, this message translates to:
  /// **'Для взрослых'**
  String get parentTitle;

  /// No description provided for @parentChildren.
  ///
  /// In ru, this message translates to:
  /// **'Дети'**
  String get parentChildren;

  /// No description provided for @parentAddChild.
  ///
  /// In ru, this message translates to:
  /// **'Добавить ребёнка'**
  String get parentAddChild;

  /// No description provided for @parentEditProfile.
  ///
  /// In ru, this message translates to:
  /// **'Изменить профиль'**
  String get parentEditProfile;

  /// No description provided for @parentProgressTitle.
  ///
  /// In ru, this message translates to:
  /// **'Прогресс: {name}'**
  String parentProgressTitle(String name);

  /// No description provided for @parentProgram.
  ///
  /// In ru, this message translates to:
  /// **'Программа: {program}'**
  String parentProgram(String program);

  /// No description provided for @parentCompleted.
  ///
  /// In ru, this message translates to:
  /// **'занятий всего'**
  String get parentCompleted;

  /// No description provided for @parentLastWeek.
  ///
  /// In ru, this message translates to:
  /// **'за 7 дней'**
  String get parentLastWeek;

  /// No description provided for @parentByArea.
  ///
  /// In ru, this message translates to:
  /// **'По направлениям'**
  String get parentByArea;

  /// No description provided for @parentByAreaNote.
  ///
  /// In ru, this message translates to:
  /// **'Это наблюдения по занятиям в приложении, а не оценка развития.'**
  String get parentByAreaNote;

  /// No description provided for @parentTriedOf.
  ///
  /// In ru, this message translates to:
  /// **'{tried} из {total}'**
  String parentTriedOf(int tried, int total);

  /// No description provided for @statusNotTried.
  ///
  /// In ru, this message translates to:
  /// **'Ещё не пробовали'**
  String get statusNotTried;

  /// No description provided for @statusTrying.
  ///
  /// In ru, this message translates to:
  /// **'Пока пробует, помогайте подсказкой'**
  String get statusTrying;

  /// No description provided for @statusConfident.
  ///
  /// In ru, this message translates to:
  /// **'Чаще справляется сам'**
  String get statusConfident;

  /// No description provided for @parentTryTogether.
  ///
  /// In ru, this message translates to:
  /// **'Попробуйте вместе'**
  String get parentTryTogether;

  /// No description provided for @parentRecent.
  ///
  /// In ru, this message translates to:
  /// **'Недавние занятия'**
  String get parentRecent;

  /// No description provided for @parentHistoryEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Пока пусто. Здесь появятся занятия, которые ребёнок прошёл.'**
  String get parentHistoryEmpty;

  /// No description provided for @parentTaskGone.
  ///
  /// In ru, this message translates to:
  /// **'Занятие больше недоступно'**
  String get parentTaskGone;

  /// No description provided for @parentWithHints.
  ///
  /// In ru, this message translates to:
  /// **', с подсказками'**
  String get parentWithHints;

  /// No description provided for @parentContent.
  ///
  /// In ru, this message translates to:
  /// **'Задания'**
  String get parentContent;

  /// No description provided for @parentContentNow.
  ///
  /// In ru, this message translates to:
  /// **'Сейчас: {source}'**
  String parentContentNow(String source);

  /// No description provided for @contentDownloaded.
  ///
  /// In ru, this message translates to:
  /// **'пакет №{version} с сервера'**
  String contentDownloaded(int version);

  /// No description provided for @contentBundled.
  ///
  /// In ru, this message translates to:
  /// **'встроенный пакет (версия {version})'**
  String contentBundled(int version);

  /// No description provided for @parentCheckUpdates.
  ///
  /// In ru, this message translates to:
  /// **'Проверить новые задания'**
  String get parentCheckUpdates;

  /// No description provided for @updateUpdated.
  ///
  /// In ru, this message translates to:
  /// **'Скачаны новые задания. Они появятся при следующем запуске приложения.'**
  String get updateUpdated;

  /// No description provided for @updateUpToDate.
  ///
  /// In ru, this message translates to:
  /// **'Новых заданий пока нет.'**
  String get updateUpToDate;

  /// No description provided for @updateNotConfigured.
  ///
  /// In ru, this message translates to:
  /// **'В этой сборке нет адреса сервера: работают встроенные задания.'**
  String get updateNotConfigured;

  /// No description provided for @updateOffline.
  ///
  /// In ru, this message translates to:
  /// **'Не получилось связаться с сервером. Задания работают и без интернета.'**
  String get updateOffline;

  /// No description provided for @updateRejected.
  ///
  /// In ru, this message translates to:
  /// **'Пакет с сервера пришёл повреждённым и не сохранён. Попробуйте позже.'**
  String get updateRejected;

  /// No description provided for @parentLanguage.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get parentLanguage;

  /// No description provided for @parentLanguageNote.
  ///
  /// In ru, this message translates to:
  /// **'Задания пока на русском: переводы появятся после проверки носителями языка.'**
  String get parentLanguageNote;

  /// No description provided for @parentData.
  ///
  /// In ru, this message translates to:
  /// **'Данные'**
  String get parentData;

  /// No description provided for @parentPrivacy.
  ///
  /// In ru, this message translates to:
  /// **'Профили и прогресс хранятся только на этом телефоне и никуда не отправляются. Мы не просим фото, голос, фамилию и точную дату рождения. В приложении нет рекламы и чатов. При проверке новых заданий приложение скачивает только сам пакет и ничего не отправляет о ребёнке.'**
  String get parentPrivacy;

  /// No description provided for @parentDeleteAll.
  ///
  /// In ru, this message translates to:
  /// **'Удалить все данные'**
  String get parentDeleteAll;

  /// No description provided for @parentDeleteAllTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить все данные?'**
  String get parentDeleteAllTitle;

  /// No description provided for @parentDeleteAllText.
  ///
  /// In ru, this message translates to:
  /// **'С телефона будут удалены все профили детей, прогресс и настройки. Вернуть их не получится. Оплаченную подписку можно будет вернуть кнопкой «Восстановить покупки».'**
  String get parentDeleteAllText;

  /// No description provided for @parentDeleteAllConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Удалить всё'**
  String get parentDeleteAllConfirm;

  /// No description provided for @month1.
  ///
  /// In ru, this message translates to:
  /// **'янв'**
  String get month1;

  /// No description provided for @month2.
  ///
  /// In ru, this message translates to:
  /// **'фев'**
  String get month2;

  /// No description provided for @month3.
  ///
  /// In ru, this message translates to:
  /// **'мар'**
  String get month3;

  /// No description provided for @month4.
  ///
  /// In ru, this message translates to:
  /// **'апр'**
  String get month4;

  /// No description provided for @month5.
  ///
  /// In ru, this message translates to:
  /// **'май'**
  String get month5;

  /// No description provided for @month6.
  ///
  /// In ru, this message translates to:
  /// **'июн'**
  String get month6;

  /// No description provided for @month7.
  ///
  /// In ru, this message translates to:
  /// **'июл'**
  String get month7;

  /// No description provided for @month8.
  ///
  /// In ru, this message translates to:
  /// **'авг'**
  String get month8;

  /// No description provided for @month9.
  ///
  /// In ru, this message translates to:
  /// **'сен'**
  String get month9;

  /// No description provided for @month10.
  ///
  /// In ru, this message translates to:
  /// **'окт'**
  String get month10;

  /// No description provided for @month11.
  ///
  /// In ru, this message translates to:
  /// **'ноя'**
  String get month11;

  /// No description provided for @month12.
  ///
  /// In ru, this message translates to:
  /// **'дек'**
  String get month12;

  /// No description provided for @parentSubscription.
  ///
  /// In ru, this message translates to:
  /// **'Подписка'**
  String get parentSubscription;

  /// No description provided for @parentSubscriptionOpen.
  ///
  /// In ru, this message translates to:
  /// **'Подробнее о подписке'**
  String get parentSubscriptionOpen;

  /// No description provided for @subTitle.
  ///
  /// In ru, this message translates to:
  /// **'Подписка LUMI Kids'**
  String get subTitle;

  /// No description provided for @subFreeTasks.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{# задание} few{# задания} many{# заданий} other{# задания}}'**
  String subFreeTasks(int count);

  /// No description provided for @subStatusFree.
  ///
  /// In ru, this message translates to:
  /// **'Сейчас бесплатная версия: в каждом направлении для каждого возраста открыто {tasks}.'**
  String subStatusFree(String tasks);

  /// No description provided for @subStatusActive.
  ///
  /// In ru, this message translates to:
  /// **'Подписка активна до {date}.'**
  String subStatusActive(String date);

  /// No description provided for @subBenefits.
  ///
  /// In ru, this message translates to:
  /// **'С подпиской открыты все задания во всех направлениях и новые задания из обновлений. Рекламы нет ни в платной, ни в бесплатной версии.'**
  String get subBenefits;

  /// No description provided for @subMonthly.
  ///
  /// In ru, this message translates to:
  /// **'Месяц: {price}'**
  String subMonthly(String price);

  /// No description provided for @subYearly.
  ///
  /// In ru, this message translates to:
  /// **'Год: {price}'**
  String subYearly(String price);

  /// No description provided for @subRestore.
  ///
  /// In ru, this message translates to:
  /// **'Восстановить покупки'**
  String get subRestore;

  /// No description provided for @subRestoreSent.
  ///
  /// In ru, this message translates to:
  /// **'Ищем ваши покупки в магазине…'**
  String get subRestoreSent;

  /// No description provided for @subTerms.
  ///
  /// In ru, this message translates to:
  /// **'Подписка продлевается автоматически, пока вы её не отмените. Отменить можно в любой момент в настройках подписок Google Play или App Store, не позже чем за сутки до продления. Оплата проходит через аккаунт магазина.'**
  String get subTerms;

  /// No description provided for @subPrivacy.
  ///
  /// In ru, this message translates to:
  /// **'Чтобы проверить покупку, приложение отправляет на наш сервер только её номер из магазина. Данные о детях не передаются.'**
  String get subPrivacy;

  /// No description provided for @subLoading.
  ///
  /// In ru, this message translates to:
  /// **'Загружаем цены из магазина…'**
  String get subLoading;

  /// No description provided for @subUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'На этом устройстве покупки недоступны.'**
  String get subUnavailable;

  /// No description provided for @subNoProducts.
  ///
  /// In ru, this message translates to:
  /// **'Подписка пока не появилась в магазине. Попробуйте позже.'**
  String get subNoProducts;

  /// No description provided for @subPending.
  ///
  /// In ru, this message translates to:
  /// **'Покупка ждёт подтверждения магазина.'**
  String get subPending;

  /// No description provided for @subActivated.
  ///
  /// In ru, this message translates to:
  /// **'Готово! Подписка активна.'**
  String get subActivated;

  /// No description provided for @subNotActive.
  ///
  /// In ru, this message translates to:
  /// **'Покупка найдена, но срок подписки закончился.'**
  String get subNotActive;

  /// No description provided for @subCanceled.
  ///
  /// In ru, this message translates to:
  /// **'Покупка отменена.'**
  String get subCanceled;

  /// No description provided for @subStoreError.
  ///
  /// In ru, this message translates to:
  /// **'Магазин сообщил об ошибке. Попробуйте ещё раз.'**
  String get subStoreError;

  /// No description provided for @subVerifyNotConfigured.
  ///
  /// In ru, this message translates to:
  /// **'В этой сборке проверка покупок ещё не подключена. Покупка останется в магазине и откроется, когда проверка заработает.'**
  String get subVerifyNotConfigured;

  /// No description provided for @subVerifyOffline.
  ///
  /// In ru, this message translates to:
  /// **'Нет связи с сервером. Проверим покупку при следующем запуске с интернетом.'**
  String get subVerifyOffline;

  /// No description provided for @subVerifyFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не получилось подтвердить покупку. Попробуйте «Восстановить покупки» позже.'**
  String get subVerifyFailed;

  /// No description provided for @lockedTitle.
  ///
  /// In ru, this message translates to:
  /// **'Это задание пока закрыто'**
  String get lockedTitle;

  /// No description provided for @lockedText.
  ///
  /// In ru, this message translates to:
  /// **'Попроси взрослого, и вы откроете его вместе.'**
  String get lockedText;

  /// No description provided for @areaTaskLockedLabel.
  ///
  /// In ru, this message translates to:
  /// **'Задание {number}, закрыто'**
  String areaTaskLockedLabel(int number);

  /// No description provided for @gateErase.
  ///
  /// In ru, this message translates to:
  /// **'Стереть'**
  String get gateErase;

  /// No description provided for @gateSubmit.
  ///
  /// In ru, this message translates to:
  /// **'Проверить ответ'**
  String get gateSubmit;

  /// No description provided for @linkPrivacy.
  ///
  /// In ru, this message translates to:
  /// **'Политика конфиденциальности'**
  String get linkPrivacy;

  /// No description provided for @linkTerms.
  ///
  /// In ru, this message translates to:
  /// **'Условия использования'**
  String get linkTerms;

  /// No description provided for @linkOpenFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не получилось открыть ссылку.'**
  String get linkOpenFailed;

  /// No description provided for @subManage.
  ///
  /// In ru, this message translates to:
  /// **'Управлять подпиской в магазине'**
  String get subManage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
