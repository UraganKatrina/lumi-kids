// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'LUMI Kids';

  @override
  String get lumiName => 'Люми';

  @override
  String get commonClose => 'Закрыть';

  @override
  String get commonBack => 'Назад';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonDelete => 'Удалить';

  @override
  String get commonError => 'Что-то пошло не так. Попробуй ещё раз чуть позже.';

  @override
  String get areaSpeech => 'Речь';

  @override
  String get areaLogic => 'Логика';

  @override
  String get areaMath => 'Числа';

  @override
  String get areaLiteracy => 'Буквы';

  @override
  String get areaMemory => 'Память';

  @override
  String get areaEmotions => 'Эмоции';

  @override
  String get areaSelfCare => 'Сам себе';

  @override
  String get areaCreativity => 'Творчество';

  @override
  String get areaWorld => 'Мир вокруг';

  @override
  String get areaMusic => 'Музыка';

  @override
  String get areaMovement => 'Движение';

  @override
  String get areaLanguages => 'Языки';

  @override
  String get programInfant => '0–1 год';

  @override
  String get programInfantHint => 'Занятия вместе со взрослым';

  @override
  String get programToddler => '1–2 года';

  @override
  String get programToddlerHint => 'Предметы, животные, первые слова';

  @override
  String get programEarly => '2–3 года';

  @override
  String get programEarlyHint => 'Цвета, формы, сортировка';

  @override
  String get programPreschool => '3–5 лет';

  @override
  String get programPreschoolHint => 'Речь, логика, счёт';

  @override
  String get programSchoolPrep => '5–7 лет';

  @override
  String get programSchoolPrepHint => 'Подготовка к школе';

  @override
  String get avatarBunny => 'Зайчик';

  @override
  String get avatarBird => 'Птичка';

  @override
  String get avatarBee => 'Пчёлка';

  @override
  String get avatarPaw => 'Котёнок';

  @override
  String get avatarFlower => 'Цветок';

  @override
  String get avatarStar => 'Звёздочка';

  @override
  String get mapForAdults => 'Для взрослых';

  @override
  String get mapGreeting => 'Привет! Я Люми.';

  @override
  String mapPlayingChild(String name) {
    return 'Играет $name. Сменить ребёнка';
  }

  @override
  String mapStarsLabel(int count) {
    return 'Звёзд: $count';
  }

  @override
  String mapIsland(String area) {
    return 'Остров $area';
  }

  @override
  String mapIslandSoon(String area) {
    return 'Остров $area, скоро';
  }

  @override
  String get mapSoon => 'скоро';

  @override
  String get mapParentLed =>
      'Для малышей до года все занятия проходят вместе со взрослым, экран только подсказывает идею.';

  @override
  String get mapAllDone => 'Все занятия пройдены! Скоро появятся новые.';

  @override
  String mapNext(String area) {
    return 'Следующее занятие: $area';
  }

  @override
  String get areaToMap => 'На карту';

  @override
  String areaTaskLabel(int number, int stars) {
    return 'Задание $number, звёзд $stars';
  }

  @override
  String get exerciseNotFound => 'Задание не найдено';

  @override
  String get resultGreat => 'Молодец!';

  @override
  String get resultPlayedTogether => 'Здорово поиграли!';

  @override
  String get resultNext => 'Дальше';

  @override
  String get resultToIsland => 'К острову';

  @override
  String get togetherTitle => 'Вместе со взрослым';

  @override
  String get togetherHint =>
      'Отложите телефон и играйте вживую. Отметьте, когда закончите.';

  @override
  String get togetherDone => 'Мы сделали!';

  @override
  String groupProgress(int placed, int total) {
    return '$placed из $total';
  }

  @override
  String get welcomeTitle => 'Здравствуйте!';

  @override
  String get welcomeText =>
      'Расскажите немного о ребёнке, чтобы Люми подобрал занятия по возрасту. Всё хранится только на этом телефоне.';

  @override
  String get profileNameQuestion => 'Как зовут ребёнка?';

  @override
  String get profileNameHint => 'Имя или прозвище';

  @override
  String get profileNameHelper => 'Фамилия не нужна';

  @override
  String get profileAvatar => 'Значок';

  @override
  String get profileBirthYear => 'Год рождения';

  @override
  String get profileBirthMonth => 'Месяц рождения';

  @override
  String get profileMonthNote =>
      'Точная дата не нужна: месяца хватает, чтобы подобрать занятия.';

  @override
  String get profileErrorName => 'Введите имя или прозвище';

  @override
  String profileErrorNameTooLong(int max) {
    return 'Имя слишком длинное, до $max букв';
  }

  @override
  String get profileErrorBirth => 'Выберите год и месяц рождения';

  @override
  String get profileErrorFuture => 'Дата рождения не может быть в будущем';

  @override
  String get profileNew => 'Новый ребёнок';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileNotFound => 'Профиль не найден';

  @override
  String get profileDelete => 'Удалить профиль';

  @override
  String profileDeleteTitle(String name) {
    return 'Удалить профиль «$name»?';
  }

  @override
  String get profileDeleteText =>
      'Профиль и весь прогресс этого ребёнка будут удалены с телефона. Вернуть их не получится.';

  @override
  String get switcherTitle => 'Кто играет?';

  @override
  String get switcherAddHint =>
      'Добавить ребёнка можно в разделе «Для взрослых».';

  @override
  String get gateTitle => 'Для взрослых';

  @override
  String gateQuestion(String a, String b) {
    return 'Сколько будет $a умножить на $b?';
  }

  @override
  String get gateWrong => 'Неверно. Вот новый вопрос.';

  @override
  String get number3 => 'три';

  @override
  String get number4 => 'четыре';

  @override
  String get number5 => 'пять';

  @override
  String get number6 => 'шесть';

  @override
  String get number7 => 'семь';

  @override
  String get number8 => 'восемь';

  @override
  String get number9 => 'девять';

  @override
  String get parentTitle => 'Для взрослых';

  @override
  String get parentChildren => 'Дети';

  @override
  String get parentAddChild => 'Добавить ребёнка';

  @override
  String get parentEditProfile => 'Изменить профиль';

  @override
  String parentProgressTitle(String name) {
    return 'Прогресс: $name';
  }

  @override
  String parentProgram(String program) {
    return 'Программа: $program';
  }

  @override
  String get parentCompleted => 'занятий всего';

  @override
  String get parentLastWeek => 'за 7 дней';

  @override
  String get parentByArea => 'По направлениям';

  @override
  String get parentByAreaNote =>
      'Это наблюдения по занятиям в приложении, а не оценка развития.';

  @override
  String parentTriedOf(int tried, int total) {
    return '$tried из $total';
  }

  @override
  String get statusNotTried => 'Ещё не пробовали';

  @override
  String get statusTrying => 'Пока пробует, помогайте подсказкой';

  @override
  String get statusConfident => 'Чаще справляется сам';

  @override
  String get parentTryTogether => 'Попробуйте вместе';

  @override
  String get parentRecent => 'Недавние занятия';

  @override
  String get parentHistoryEmpty =>
      'Пока пусто. Здесь появятся занятия, которые ребёнок прошёл.';

  @override
  String get parentTaskGone => 'Занятие больше недоступно';

  @override
  String get parentWithHints => ', с подсказками';

  @override
  String get parentContent => 'Задания';

  @override
  String parentContentNow(String source) {
    return 'Сейчас: $source';
  }

  @override
  String contentDownloaded(int version) {
    return 'пакет №$version с сервера';
  }

  @override
  String contentBundled(int version) {
    return 'встроенный пакет (версия $version)';
  }

  @override
  String get parentCheckUpdates => 'Проверить новые задания';

  @override
  String get updateUpdated =>
      'Скачаны новые задания. Они появятся при следующем запуске приложения.';

  @override
  String get updateUpToDate => 'Новых заданий пока нет.';

  @override
  String get updateNotConfigured =>
      'В этой сборке нет адреса сервера: работают встроенные задания.';

  @override
  String get updateOffline =>
      'Не получилось связаться с сервером. Задания работают и без интернета.';

  @override
  String get updateRejected =>
      'Пакет с сервера пришёл повреждённым и не сохранён. Попробуйте позже.';

  @override
  String get parentLanguage => 'Язык';

  @override
  String get parentLanguageNote =>
      'Задания пока на русском: переводы появятся после проверки носителями языка.';

  @override
  String get parentData => 'Данные';

  @override
  String get parentPrivacy =>
      'Профили и прогресс хранятся только на этом телефоне и никуда не отправляются. Мы не просим фото, голос, фамилию и точную дату рождения. В приложении нет рекламы и чатов. При проверке новых заданий приложение скачивает только сам пакет и ничего не отправляет о ребёнке.';

  @override
  String get parentDeleteAll => 'Удалить все данные';

  @override
  String get parentDeleteAllTitle => 'Удалить все данные?';

  @override
  String get parentDeleteAllText =>
      'С телефона будут удалены все профили детей, прогресс и настройки. Вернуть их не получится. Оплаченную подписку можно будет вернуть кнопкой «Восстановить покупки».';

  @override
  String get parentDeleteAllConfirm => 'Удалить всё';

  @override
  String get month1 => 'янв';

  @override
  String get month2 => 'фев';

  @override
  String get month3 => 'мар';

  @override
  String get month4 => 'апр';

  @override
  String get month5 => 'май';

  @override
  String get month6 => 'июн';

  @override
  String get month7 => 'июл';

  @override
  String get month8 => 'авг';

  @override
  String get month9 => 'сен';

  @override
  String get month10 => 'окт';

  @override
  String get month11 => 'ноя';

  @override
  String get month12 => 'дек';

  @override
  String get parentSubscription => 'Подписка';

  @override
  String get parentSubscriptionOpen => 'Подробнее о подписке';

  @override
  String get subTitle => 'Подписка LUMI Kids';

  @override
  String subFreeTasks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# задания',
      many: '# заданий',
      few: '# задания',
      one: '# задание',
    );
    return '$_temp0';
  }

  @override
  String subStatusFree(String tasks) {
    return 'Сейчас бесплатная версия: в каждом направлении для каждого возраста открыто $tasks.';
  }

  @override
  String subStatusActive(String date) {
    return 'Подписка активна до $date.';
  }

  @override
  String get subBenefits =>
      'С подпиской открыты все задания во всех направлениях и новые задания из обновлений. Рекламы нет ни в платной, ни в бесплатной версии.';

  @override
  String subMonthly(String price) {
    return 'Месяц: $price';
  }

  @override
  String subYearly(String price) {
    return 'Год: $price';
  }

  @override
  String get subRestore => 'Восстановить покупки';

  @override
  String get subRestoreSent => 'Ищем ваши покупки в магазине…';

  @override
  String get subTerms =>
      'Подписка продлевается автоматически, пока вы её не отмените. Отменить можно в любой момент в настройках подписок Google Play или App Store, не позже чем за сутки до продления. Оплата проходит через аккаунт магазина.';

  @override
  String get subPrivacy =>
      'Чтобы проверить покупку, приложение отправляет на наш сервер только её номер из магазина. Данные о детях не передаются.';

  @override
  String get subLoading => 'Загружаем цены из магазина…';

  @override
  String get subUnavailable => 'На этом устройстве покупки недоступны.';

  @override
  String get subNoProducts =>
      'Подписка пока не появилась в магазине. Попробуйте позже.';

  @override
  String get subPending => 'Покупка ждёт подтверждения магазина.';

  @override
  String get subActivated => 'Готово! Подписка активна.';

  @override
  String get subNotActive => 'Покупка найдена, но срок подписки закончился.';

  @override
  String get subCanceled => 'Покупка отменена.';

  @override
  String get subStoreError => 'Магазин сообщил об ошибке. Попробуйте ещё раз.';

  @override
  String get subVerifyNotConfigured =>
      'В этой сборке проверка покупок ещё не подключена. Покупка останется в магазине и откроется, когда проверка заработает.';

  @override
  String get subVerifyOffline =>
      'Нет связи с сервером. Проверим покупку при следующем запуске с интернетом.';

  @override
  String get subVerifyFailed =>
      'Не получилось подтвердить покупку. Попробуйте «Восстановить покупки» позже.';

  @override
  String get lockedTitle => 'Это задание пока закрыто';

  @override
  String get lockedText => 'Попроси взрослого, и вы откроете его вместе.';

  @override
  String areaTaskLockedLabel(int number) {
    return 'Задание $number, закрыто';
  }

  @override
  String get gateErase => 'Стереть';

  @override
  String get gateSubmit => 'Проверить ответ';

  @override
  String get linkPrivacy => 'Политика конфиденциальности';

  @override
  String get linkTerms => 'Условия использования';

  @override
  String get linkOpenFailed => 'Не получилось открыть ссылку.';

  @override
  String get subManage => 'Управлять подпиской в магазине';
}
