// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get appTitle => 'LUMI Kids';

  @override
  String get lumiName => 'Lumi';

  @override
  String get commonClose => 'Yopish';

  @override
  String get commonBack => 'Orqaga';

  @override
  String get commonCancel => 'Bekor qilish';

  @override
  String get commonSave => 'Saqlash';

  @override
  String get commonDelete => 'O\'chirish';

  @override
  String get commonError =>
      'Nimadir xato ketdi. Birozdan keyin yana urinib ko\'r.';

  @override
  String get areaSpeech => 'Nutq';

  @override
  String get areaLogic => 'Mantiq';

  @override
  String get areaMath => 'Sonlar';

  @override
  String get areaLiteracy => 'Harflar';

  @override
  String get areaMemory => 'Xotira';

  @override
  String get areaEmotions => 'Hissiyotlar';

  @override
  String get areaSelfCare => 'O\'zim';

  @override
  String get areaCreativity => 'Ijod';

  @override
  String get areaWorld => 'Atrof-olam';

  @override
  String get areaMusic => 'Musiqa';

  @override
  String get areaMovement => 'Harakat';

  @override
  String get areaLanguages => 'Tillar';

  @override
  String get programInfant => '0–1 yosh';

  @override
  String get programInfantHint => 'Kattalar bilan birga mashg\'ulotlar';

  @override
  String get programToddler => '1–2 yosh';

  @override
  String get programToddlerHint => 'Buyumlar, hayvonlar, ilk so\'zlar';

  @override
  String get programEarly => '2–3 yosh';

  @override
  String get programEarlyHint => 'Ranglar, shakllar, saralash';

  @override
  String get programPreschool => '3–5 yosh';

  @override
  String get programPreschoolHint => 'Nutq, mantiq, sanash';

  @override
  String get programSchoolPrep => '5–7 yosh';

  @override
  String get programSchoolPrepHint => 'Maktabga tayyorgarlik';

  @override
  String get avatarBunny => 'Quyoncha';

  @override
  String get avatarBird => 'Qushcha';

  @override
  String get avatarBee => 'Asalarixon';

  @override
  String get avatarPaw => 'Mushukcha';

  @override
  String get avatarFlower => 'Gulcha';

  @override
  String get avatarStar => 'Yulduzcha';

  @override
  String get mapForAdults => 'Kattalar uchun';

  @override
  String get mapGreeting => 'Salom! Men Lumiman.';

  @override
  String mapPlayingChild(String name) {
    return '$name o\'ynayapti. Bolani almashtirish';
  }

  @override
  String mapStarsLabel(int count) {
    return 'Yulduzlar: $count';
  }

  @override
  String mapIsland(String area) {
    return '$area oroli';
  }

  @override
  String mapIslandSoon(String area) {
    return '$area oroli, tez orada';
  }

  @override
  String get mapSoon => 'tez orada';

  @override
  String get mapParentLed =>
      'Bir yoshgacha bo\'lgan chaqaloqlar uchun barcha mashg\'ulotlar kattalar bilan birga o\'tadi, ekran faqat g\'oya beradi.';

  @override
  String get mapAllDone =>
      'Barcha mashg\'ulotlar bajarildi! Tez orada yangilari paydo bo\'ladi.';

  @override
  String mapNext(String area) {
    return 'Keyingi mashg\'ulot: $area';
  }

  @override
  String get areaToMap => 'Xaritaga';

  @override
  String areaTaskLabel(int number, int stars) {
    return '$number-topshiriq, yulduzlar $stars';
  }

  @override
  String get exerciseNotFound => 'Topshiriq topilmadi';

  @override
  String get resultGreat => 'Barakalla!';

  @override
  String get resultPlayedTogether => 'Ajoyib o\'ynadik!';

  @override
  String get resultNext => 'Keyingisi';

  @override
  String get resultToIsland => 'Orolga';

  @override
  String get togetherTitle => 'Kattalar bilan birga';

  @override
  String get togetherHint =>
      'Telefonni chetga qo\'yib, jonli o\'ynang. Tugatgach, belgilang.';

  @override
  String get togetherDone => 'Biz bajardik!';

  @override
  String groupProgress(int placed, int total) {
    return '$total tadan $placed';
  }

  @override
  String get welcomeTitle => 'Assalomu alaykum!';

  @override
  String get welcomeText =>
      'Lumi yoshiga mos mashg\'ulotlarni tanlashi uchun bola haqida bir oz aytib bering. Hammasi faqat shu telefonda saqlanadi.';

  @override
  String get profileNameQuestion => 'Bolaning ismi nima?';

  @override
  String get profileNameHint => 'Ism yoki laqab';

  @override
  String get profileNameHelper => 'Familiya kerak emas';

  @override
  String get profileAvatar => 'Belgi';

  @override
  String get profileBirthYear => 'Tug\'ilgan yil';

  @override
  String get profileBirthMonth => 'Tug\'ilgan oy';

  @override
  String get profileMonthNote =>
      'Aniq sana kerak emas: mashg\'ulotlarni tanlash uchun oy yetarli.';

  @override
  String get profileErrorName => 'Ism yoki laqab kiriting';

  @override
  String profileErrorNameTooLong(int max) {
    return 'Ism juda uzun, $max ta harfgacha';
  }

  @override
  String get profileErrorBirth => 'Tug\'ilgan yil va oyni tanlang';

  @override
  String get profileErrorFuture =>
      'Tug\'ilgan sana kelajakda bo\'lishi mumkin emas';

  @override
  String get profileNew => 'Yangi bola';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileNotFound => 'Profil topilmadi';

  @override
  String get profileDelete => 'Profilni o\'chirish';

  @override
  String profileDeleteTitle(String name) {
    return '«$name» profilini o\'chirasizmi?';
  }

  @override
  String get profileDeleteText =>
      'Bu bolaning profili va butun natijalari telefondan o\'chiriladi. Ularni qaytarib bo\'lmaydi.';

  @override
  String get switcherTitle => 'Kim o\'ynayapti?';

  @override
  String get switcherAddHint =>
      'Bolani «Kattalar uchun» bo\'limida qo\'shish mumkin.';

  @override
  String get gateTitle => 'Kattalar uchun';

  @override
  String gateQuestion(String a, String b) {
    return '$a ni $b ga ko\'paytirsa, nechchi bo\'ladi?';
  }

  @override
  String get gateWrong => 'Noto\'g\'ri. Mana yangi savol.';

  @override
  String get number3 => 'uch';

  @override
  String get number4 => 'to\'rt';

  @override
  String get number5 => 'besh';

  @override
  String get number6 => 'olti';

  @override
  String get number7 => 'yetti';

  @override
  String get number8 => 'sakkiz';

  @override
  String get number9 => 'to\'qqiz';

  @override
  String get parentTitle => 'Kattalar uchun';

  @override
  String get parentChildren => 'Bolalar';

  @override
  String get parentAddChild => 'Bola qo\'shish';

  @override
  String get parentEditProfile => 'Profilni tahrirlash';

  @override
  String parentProgressTitle(String name) {
    return 'Natijalar: $name';
  }

  @override
  String parentProgram(String program) {
    return 'Dastur: $program';
  }

  @override
  String get parentCompleted => 'jami mashg\'ulot';

  @override
  String get parentLastWeek => '7 kunda';

  @override
  String get parentByArea => 'Yo\'nalishlar bo\'yicha';

  @override
  String get parentByAreaNote =>
      'Bu ilovadagi mashg\'ulotlar bo\'yicha kuzatuvlar, rivojlanish bahosi emas.';

  @override
  String parentTriedOf(int tried, int total) {
    return '$total tadan $tried';
  }

  @override
  String get statusNotTried => 'Hali urinib ko\'rilmagan';

  @override
  String get statusTrying => 'Hozircha urinyapti, maslahat bilan yordam bering';

  @override
  String get statusConfident => 'Ko\'pincha o\'zi uddalaydi';

  @override
  String get parentTryTogether => 'Birga sinab ko\'ring';

  @override
  String get parentRecent => 'So\'nggi mashg\'ulotlar';

  @override
  String get parentHistoryEmpty =>
      'Hozircha bo\'sh. Bola bajargan mashg\'ulotlar shu yerda paydo bo\'ladi.';

  @override
  String get parentTaskGone => 'Mashg\'ulot endi mavjud emas';

  @override
  String get parentWithHints => ', maslahatlar bilan';

  @override
  String get parentContent => 'Topshiriqlar';

  @override
  String parentContentNow(String source) {
    return 'Hozir: $source';
  }

  @override
  String contentDownloaded(int version) {
    return 'serverdan $version-to\'plam';
  }

  @override
  String contentBundled(int version) {
    return 'ichki to\'plam ($version-versiya)';
  }

  @override
  String get parentCheckUpdates => 'Yangi topshiriqlarni tekshirish';

  @override
  String get updateUpdated =>
      'Yangi topshiriqlar yuklandi. Ular ilova keyingi safar ochilganda paydo bo\'ladi.';

  @override
  String get updateUpToDate => 'Hozircha yangi topshiriqlar yo\'q.';

  @override
  String get updateNotConfigured =>
      'Bu yig\'mada server manzili yo\'q: ichki topshiriqlar ishlaydi.';

  @override
  String get updateOffline =>
      'Server bilan bog\'lanib bo\'lmadi. Topshiriqlar internetsiz ham ishlaydi.';

  @override
  String get updateRejected =>
      'Serverdan kelgan to\'plam buzilgan va saqlanmadi. Keyinroq urinib ko\'ring.';

  @override
  String get parentLanguage => 'Til';

  @override
  String get parentLanguageNote =>
      'Topshiriqlar hozircha rus tilida: tarjimalar ona tilida so\'zlashuvchilar tekshirgandan keyin paydo bo\'ladi.';

  @override
  String get parentData => 'Ma\'lumotlar';

  @override
  String get parentPrivacy =>
      'Profillar va natijalar faqat shu telefonda saqlanadi va hech qayerga yuborilmaydi. Biz rasm, ovoz, familiya va aniq tug\'ilgan sanani so\'ramaymiz. Ilovada reklama va chatlar yo\'q. Yangi topshiriqlarni tekshirganda ilova faqat to\'plamni yuklab oladi va bola haqida hech narsa yubormaydi.';

  @override
  String get parentDeleteAll => 'Barcha ma\'lumotlarni o\'chirish';

  @override
  String get parentDeleteAllTitle => 'Barcha ma\'lumotlar o\'chirilsinmi?';

  @override
  String get parentDeleteAllText =>
      'Telefondan barcha bolalar profillari, natijalar va sozlamalar o\'chiriladi. Ularni qaytarib bo\'lmaydi. To\'langan obunani «Xaridlarni tiklash» tugmasi bilan qaytarish mumkin.';

  @override
  String get parentDeleteAllConfirm => 'Hammasini o\'chirish';

  @override
  String get month1 => 'yan';

  @override
  String get month2 => 'fev';

  @override
  String get month3 => 'mar';

  @override
  String get month4 => 'apr';

  @override
  String get month5 => 'may';

  @override
  String get month6 => 'iyn';

  @override
  String get month7 => 'iyl';

  @override
  String get month8 => 'avg';

  @override
  String get month9 => 'sen';

  @override
  String get month10 => 'okt';

  @override
  String get month11 => 'noy';

  @override
  String get month12 => 'dek';

  @override
  String get parentSubscription => 'Obuna';

  @override
  String get parentSubscriptionOpen => 'Obuna haqida batafsil';

  @override
  String get subTitle => 'LUMI Kids obunasi';

  @override
  String subFreeTasks(int count) {
    return '$count ta topshiriq';
  }

  @override
  String subStatusFree(String tasks) {
    return 'Hozir bepul versiya: har bir yo\'nalishda har bir yosh uchun $tasks ochiq.';
  }

  @override
  String subStatusActive(String date) {
    return 'Obuna $date gacha faol.';
  }

  @override
  String get subBenefits =>
      'Obuna bilan barcha yo\'nalishlardagi barcha topshiriqlar va yangilanishlardagi yangi topshiriqlar ochiladi. Pullik va bepul versiyada ham reklama yo\'q.';

  @override
  String subMonthly(String price) {
    return 'Bir oy: $price';
  }

  @override
  String subYearly(String price) {
    return 'Bir yil: $price';
  }

  @override
  String get subRestore => 'Xaridlarni tiklash';

  @override
  String get subRestoreSent => 'Do\'kondan xaridlaringizni qidiryapmiz…';

  @override
  String get subTerms =>
      'Obuna siz bekor qilmaguningizcha avtomatik uzaytiriladi. Uni istalgan vaqtda Google Play yoki App Store obuna sozlamalarida, uzaytirishdan kamida bir kun oldin bekor qilish mumkin. To\'lov do\'kon akkaunti orqali o\'tadi.';

  @override
  String get subPrivacy =>
      'Xaridni tekshirish uchun ilova serverimizga faqat do\'kondagi xarid raqamini yuboradi. Bolalar haqidagi ma\'lumotlar yuborilmaydi.';

  @override
  String get subLoading => 'Do\'kondan narxlar yuklanmoqda…';

  @override
  String get subUnavailable => 'Bu qurilmada xaridlar mavjud emas.';

  @override
  String get subNoProducts =>
      'Obuna hali do\'konda paydo bo\'lmadi. Keyinroq urinib ko\'ring.';

  @override
  String get subPending => 'Xarid do\'kon tasdig\'ini kutmoqda.';

  @override
  String get subActivated => 'Tayyor! Obuna faol.';

  @override
  String get subNotActive => 'Xarid topildi, lekin obuna muddati tugagan.';

  @override
  String get subCanceled => 'Xarid bekor qilindi.';

  @override
  String get subStoreError =>
      'Do\'kon xatolik haqida xabar berdi. Yana urinib ko\'ring.';

  @override
  String get subVerifyNotConfigured =>
      'Bu yig\'mada xaridlarni tekshirish hali ulanmagan. Xarid do\'konda qoladi va tekshirish ishlaganda ochiladi.';

  @override
  String get subVerifyOffline =>
      'Server bilan aloqa yo\'q. Xaridni keyingi safar internet bilan ochilganda tekshiramiz.';

  @override
  String get subVerifyFailed =>
      'Xaridni tasdiqlab bo\'lmadi. Keyinroq «Xaridlarni tiklash»ni bosing.';

  @override
  String get lockedTitle => 'Bu topshiriq hozircha yopiq';

  @override
  String get lockedText => 'Kattalardan so\'ra, birga ochasizlar.';

  @override
  String areaTaskLockedLabel(int number) {
    return '$number-topshiriq, yopiq';
  }

  @override
  String get gateErase => 'O\'chirish';

  @override
  String get gateSubmit => 'Javobni tekshirish';

  @override
  String get linkPrivacy => 'Maxfiylik siyosati';

  @override
  String get linkTerms => 'Foydalanish shartlari';

  @override
  String get linkOpenFailed => 'Havolani ochib bo\'lmadi.';

  @override
  String get subManage => 'Obunani do\'konda boshqarish';
}
