// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'ميمورو';

  @override
  String get welcomeTitle => 'مرحبا بك في ميمورو';

  @override
  String get welcomeSubtitle => 'ملاحظاتك وذكرياتك في مكان واحد.';

  @override
  String get startButton => 'ابدأ';

  @override
  String get chooseFlowTitle => 'اختر مسارك';

  @override
  String get chooseFlowPatient => 'مريض';

  @override
  String get chooseFlowCaregiver => 'مقدم الرعاية';

  @override
  String get comingSoonLabel => 'قريبًا';

  @override
  String get chooseFlowCaregiverComingSoon => 'اربط حسابك بالمريض، راجع خطط الرعاية، وتابع الأدوية والأنشطة.';

  @override
  String get loginTitle => 'تسجيل الدخول';

  @override
  String get registerTitle => 'إنشاء حساب';

  @override
  String get registerWelcomeTitle => 'أنشئ حسابك';

  @override
  String get registerWelcomeSubtitle => 'سجّل في ثوانٍ ودعنا نساعدك على تذكّر ما يهمّك أكثر.';

  @override
  String get genderLabel => 'النوع';

  @override
  String get genderMale => 'ذكر';

  @override
  String get genderFemale => 'أنثى';

  @override
  String get genderSelectHint => 'اختر النوع';

  @override
  String get genderRequired => 'يرجى اختيار النوع.';

  @override
  String get phoneRequired => 'يرجى إدخال رقم الهاتف.';

  @override
  String get invalidPhoneNumber => 'أدخل رقمًا صالحًا للدولة المختارة.';

  @override
  String get ageHint => 'العمر';

  @override
  String get fieldHintAge => '25';

  @override
  String get ageInvalid => 'أدخل عمرًا صحيحًا بين 1 و 120.';

  @override
  String get termsAgreementPrefix => 'أوافق على ';

  @override
  String get termsAgreementLink => 'الشروط والأحكام';

  @override
  String get termsRequired => 'يرجى الموافقة على الشروط والأحكام.';

  @override
  String get termsTitle => 'الشروط والأحكام';

  @override
  String get termsBody => 'هذا نص تجريبي مؤقت. استبدله بشروطك وسياسة الخصوصية قبل الإطلاق الفعلي.';

  @override
  String get dialogClose => 'إغلاق';

  @override
  String get imagePickerError => 'تعذّر فتح الصور. أوقف التطبيق بالكامل، نفّذ \"flutter clean\" ثم في مجلد ios نفّذ \"pod install\"، ثم أعد البناء (وليس إعادة التحميل السريعة).';

  @override
  String get registerHaveAccountPrefix => 'لديك حساب بالفعل؟ ';

  @override
  String get registerSignInLink => 'تسجيل الدخول';

  @override
  String get emailHint => 'البريد الإلكتروني';

  @override
  String get passwordHint => 'كلمة المرور';

  @override
  String get passwordVisibilityShow => 'إظهار كلمة المرور';

  @override
  String get passwordVisibilityHide => 'إخفاء كلمة المرور';

  @override
  String get fieldHintEmail => 'you@example.com';

  @override
  String get fieldHintPassword => 'أدخل كلمة المرور';

  @override
  String get fieldHintName => 'الاسم الكامل';

  @override
  String get fieldHintPhone => '01xxxxxxxxx';

  @override
  String get fieldHintImageUrl => 'https://example.com/photo.jpg';

  @override
  String get profilePhotoLabel => 'الصورة الشخصية';

  @override
  String get chooseFromGallery => 'اختر من المعرض';

  @override
  String get removeProfilePhoto => 'إزالة الصورة';

  @override
  String get nameHint => 'الاسم';

  @override
  String get phoneHint => 'رقم الهاتف';

  @override
  String get loginButton => 'دخول';

  @override
  String get createAccountButton => 'إنشاء حساب';

  @override
  String get goToRegister => 'ليس لديك حساب؟ سجل الآن';

  @override
  String get imageButton => 'إضافة صورة شخصية';

  @override
  String get imageHint => 'رابط الصورة الشخصية';

  @override
  String get rememberMe => 'تذكرني';

  @override
  String get forgotPasswordLink => 'نسيت كلمة المرور؟';

  @override
  String get forgotPasswordTitle => 'نسيت كلمة المرور';

  @override
  String get forgotPasswordSubtitle => 'أدخل بريدك الإلكتروني وسنرسل لك رابطًا لإعادة تعيين كلمة المرور.';

  @override
  String get forgotPasswordSendButton => 'إرسال';

  @override
  String get passwordResetEmailSent => 'إن وُجد حساب لهذا البريد، ستصلك تعليمات إعادة التعيين قريبًا.';

  @override
  String get loginWelcomeBack => 'مرحبًا بعودتك';

  @override
  String get loginJourneySubtitle => 'سجّل الدخول لمتابعة رحلتك معنا.';

  @override
  String get loginNoAccountPrefix => 'ليس لديك حساب؟ ';

  @override
  String get loginCreateAccountLink => 'إنشاء حساب';

  @override
  String get testAccountButton => 'استخدام حساب تجريبي';

  @override
  String get logoutButton => 'تسجيل الخروج';

  @override
  String get usingTestAccount => 'أنت مسجل الدخول بحساب تجريبي.';

  @override
  String get authErrorMessage => 'فشل تسجيل الدخول. تحقق من البيانات وحاول مرة أخرى.';

  @override
  String get authInvalidCredentials => 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get authPatientLoginOnlyMessage => 'هذا الحساب يتبع مسار مقدم الرعاية. يرجى تسجيل الدخول من مسار مقدم الرعاية.';

  @override
  String get authCaregiverLoginOnlyMessage => 'هذا الحساب يتبع مسار المريض. يرجى تسجيل الدخول من مسار المريض.';

  @override
  String get firebaseNotConfigured => 'لم يُعد Firebase على هذا الجهاز. شغّل التطبيق بإعداد firebase_options صالح.';

  @override
  String get firestorePermissionDenied => 'تعذّر حفظ ملفك (رفض قاعدة البيانات للصلاحية). اطلب من المطوّر تحديث قواعد أمان Firestore لمجموعة patients أو users.';

  @override
  String get passwordTooShort => 'كلمة المرور يجب أن تكون 6 أحرف على الأقل.';

  @override
  String get registerErrorWeakPassword => 'كلمة المرور ضعيفة. استخدم 6 أحرف على الأقل.';

  @override
  String get registerErrorEmailInUse => 'هذا البريد مسجّل مسبقًا. جرّب تسجيل الدخول.';

  @override
  String get registerErrorInvalidEmail => 'عنوان البريد غير صالح.';

  @override
  String get registerErrorOperationNotAllowed => 'التسجيل بالبريد وكلمة المرور معطّل في مشروع Firebase.';

  @override
  String get registerErrorNetwork => 'خطأ في الشبكة. تحقق من الاتصال وحاول مرة أخرى.';

  @override
  String get registerSuccess => 'تم إنشاء الحساب. سجّل الدخول ببريدك وكلمة المرور.';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get currentUser => 'المستخدم الحالي';

  @override
  String get guestUser => 'زائر';

  @override
  String get nextPageSnackBar => 'لنبدأ بناء صفحتك التالية!';

  @override
  String get tabHome => 'الرئيسية';

  @override
  String get tabChat => 'الدردشة';

  @override
  String get tabGames => 'الألعاب';

  @override
  String get tabMedicine => 'الدواء';

  @override
  String get tabProfile => 'الملف الشخصي';

  @override
  String get fabTapped => 'تم الضغط على الزر العائم';

  @override
  String get chatCardTitle => 'روبوت دردشة مجاني';

  @override
  String get chatCardSubtitle => 'اسأل أي سؤال واحصل على مساعدة فورية.';

  @override
  String get chatBotTitle => 'مساعد الدردشة الذكي';

  @override
  String get chatMessagesTitle => 'الرسائل';

  @override
  String get chatSearchHint => 'ابحث عن شخص...';

  @override
  String get chatAssistantCardTitle => 'مساعد الدردشة';

  @override
  String get chatAssistantCardSubtitle => 'احصل على إجابات ومعلومات مفيدة في أي وقت عبر مساعدنا الذكي الودود';

  @override
  String get chatCaregiverCardTitle => 'المُعتني';

  @override
  String get chatCaregiverCardSubtitle => 'تواصل مباشرة مع المُعتني المخصص لك للحصول على دعم ومساعدة شخصية';

  @override
  String get chatAssistantTime => '2:15\nم';

  @override
  String get chatCaregiverTime => '2:15\nص';

  @override
  String get languageLabel => 'اللغة';

  @override
  String get englishLabel => 'الإنجليزية';

  @override
  String get arabicLabel => 'العربية';

  @override
  String get chatMedicalDisclaimer => 'هذه الإجابات للتوعية فقط وليست بديلا عن الاستشارة الطبية.';

  @override
  String get chatChooseQuestion => 'اختر أي سؤال عن ألزهايمر وسأجيبك:';

  @override
  String get gamesNewChallengeLabel => 'تحدٍ جديد';

  @override
  String get gamesFeaturedHeroTitle => 'اختبر ذاكرتك';

  @override
  String get gamesFeaturedHeroSubtitle => 'تمرين يومي لمدة 5 دقائق لمتابعة صحتك الإدراكية';

  @override
  String get gamesHubStartNow => 'ابدأ الآن';

  @override
  String get gamesAdvancedGamesSectionTitle => 'ألعاب متقدمة';

  @override
  String get gamesOnlineSectionTitle => 'ألعاب عبر الإنترنت';

  @override
  String get gamesSudokuTitle => 'لغز سودوكو';

  @override
  String get gamesSudokuSubtitle => 'تحدي الكلمات';

  @override
  String get gamesSimonSaysTitle => 'ألعاب سيمون يقول';

  @override
  String get gamesSimonSaysSubtitle => 'لغز الأرقام';

  @override
  String get gamesChessTitle => 'شطرنج';

  @override
  String get gamesChessSubtitle => 'ورق كلاسيكي';

  @override
  String get gamesPlay => 'العب';

  @override
  String get gamesImageMemoryTestTitle => 'اختبار ذاكرة الصور';

  @override
  String get gamesImageMemoryTestSubtitle => 'اختبر ذاكرتك بالصور';

  @override
  String get gamesDailyRecallTestTitle => 'اختبار التذكر اليومي';

  @override
  String get gamesDailyRecallTestSubtitle => 'ذكّر يومك';

  @override
  String get gameMemoryTitle => 'لعبة مطابقة بطاقات الذاكرة';

  @override
  String get gameMemorySubtitle => 'طابق كل أزواج الأيقونات للفوز.';

  @override
  String get gameSequenceTitle => 'لعبة تسلسل الذاكرة';

  @override
  String get gameSequenceSubtitle => 'شاهد الترتيب ثم أعده.';

  @override
  String get gameMathTitle => 'تحدي الرياضيات السريع';

  @override
  String get gameMathSubtitle => 'حل مسائل رياضية بسيطة بأسرع ما يمكن.';

  @override
  String get restartTooltip => 'إعادة التشغيل';

  @override
  String get closeLabel => 'إغلاق';

  @override
  String get playAgainLabel => 'العب مرة أخرى';

  @override
  String movesLabel(Object count) {
    return 'الحركات: $count';
  }

  @override
  String get youWinTitle => 'أحسنت! فزت';

  @override
  String memoryWinMessage(Object moves) {
    return 'ذاكرة رائعة. أنهيت اللعبة في $moves حركة.';
  }

  @override
  String get sequenceGameOverTitle => 'انتهت اللعبة';

  @override
  String sequenceGameOverMessage(Object level) {
    return 'وصلت إلى المستوى $level. حاول مرة أخرى!';
  }

  @override
  String sequenceLevelBest(Object level, Object best) {
    return 'المستوى: $level   الأفضل: $best';
  }

  @override
  String get sequenceWatch => 'شاهد التسلسل...';

  @override
  String get sequenceRepeat => 'الآن كرر التسلسل';

  @override
  String get sequenceReady => 'استعد...';

  @override
  String get mathTimeUpTitle => 'انتهى الوقت!';

  @override
  String mathScoreBest(Object score, Object best) {
    return 'درجتك: $score\nأفضل درجة: $best';
  }

  @override
  String mathHeader(Object seconds, Object score, Object best) {
    return 'الوقت: $seconds ث   الدرجة: $score   الأفضل: $best';
  }

  @override
  String get mathYourAnswer => 'إجابتك';

  @override
  String get submitLabel => 'إرسال';

  @override
  String get cancel => 'إلغاء';

  @override
  String get changeLanguageTooltip => 'تغيير اللغة';

  @override
  String get homeGreetingGoodMorning => 'صباح الخير';

  @override
  String get homeGreetingGoodAfternoon => 'مساء الخير';

  @override
  String get homeGreetingGoodEvening => 'مساء الخير';

  @override
  String get homeMedicationReminderTitle => 'تذكير الدواء';

  @override
  String get homeMedicationReminderSubtitle => 'الجرعة التالية الساعة 2:00 م';

  @override
  String get homeMinutesLabel => 'دقيقة';

  @override
  String get homeTakenButton => 'تم الأخذ';

  @override
  String get homeThisWeekProgressTitle => 'تقدمك هذا الأسبوع';

  @override
  String get homeWeekdayMon => 'اثنين';

  @override
  String get homeWeekdayTue => 'ثلاثاء';

  @override
  String get homeWeekdayWed => 'أربعاء';

  @override
  String get homeWeekdayThu => 'خميس';

  @override
  String get homeWeekdayFri => 'جمعة';

  @override
  String get homeWeekdaySat => 'سبت';

  @override
  String get homeWeekdaySun => 'أحد';

  @override
  String get homeAdherenceMessage => 'الالتزام بالدواء 85% هذا الأسبوع';

  @override
  String get quickActionViewAll => 'عرض الكل';

  @override
  String get quickActionStart => 'ابدأ';

  @override
  String get quickActionActivity => 'النشاط';

  @override
  String get quickActionMemoryTest => 'اختبار الذاكرة';

  @override
  String get quickActionFamily => 'العائلة';

  @override
  String get profileTitleMyProfile => 'ملفي الشخصي';

  @override
  String get profileYouAreSafe => 'أنت بأمان 💙';

  @override
  String get profileCallCaregiver => 'اتصل بالمُعتنِي';

  @override
  String get profileMessageButton => 'رسالة';

  @override
  String get profileYourCaregiver => 'المُعتنِي بك';

  @override
  String get profilePlaceholderCaregiverName => 'سارة جونسون';

  @override
  String get profileNextMedication => 'الدواء التالي';

  @override
  String get profilePlaceholderNextMedTime => 'اليوم 2:00 م';

  @override
  String get profileTodaysActivity => 'نشاط اليوم';

  @override
  String get profilePlaceholderActivity => 'نزهة في الحديقة';

  @override
  String get profileSosSettings => 'إعدادات الطوارئ SOS';

  @override
  String get profilePlaceholderUserName => 'محمد علي';

  @override
  String get settingsScreenTitle => 'الإعدادات';

  @override
  String get settingsLanguageSubtitle => 'اختر لغتك';

  @override
  String get settingsNotificationsTitle => 'الإشعارات';

  @override
  String get settingsNotificationsSubtitle => 'استلم التذكيرات والتنبيهات';

  @override
  String get settingsSoundTitle => 'الصوت';

  @override
  String get settingsSoundSubtitle => 'تفعيل المؤثرات الصوتية';

  @override
  String get settingsNeedHelpTitle => 'تحتاج مساعدة؟';

  @override
  String get settingsNeedHelpSubtitle => 'تواصل مع الدعم إذا احتجت إلى مساعدة';

  @override
  String get settingsContactSupport => 'اتصل بالدعم';

  @override
  String get medScreenTitle => 'الدواء';

  @override
  String medMedicationsCount(Object count) {
    return '$count أدوية';
  }

  @override
  String get medDueToday => 'مستحقة اليوم';

  @override
  String get medProgressLabel => 'التقدم';

  @override
  String medProgressFraction(Object current, Object total) {
    return '$current من $total';
  }

  @override
  String get medSectionMorning => 'الصباح';

  @override
  String get medSectionAfternoon => 'بعد الظهر';

  @override
  String get medSectionEvening => 'المساء';

  @override
  String get medDrugAspirin => 'أسبرين';

  @override
  String get medDrugMetformin => 'ميتفورمين';

  @override
  String get medDrugVitaminD => 'فيتامين د';

  @override
  String get medDose100mgTablet => 'قرص 100 مجم';

  @override
  String get medDose500mgTablet => 'قرص 500 مجم';

  @override
  String get medDose1000IuCapsule => 'كبسولة 1000 وحدة';

  @override
  String get medTime800Am => '8:00 ص';

  @override
  String get medTime200Pm => '2:00 م';

  @override
  String get medTime700Pm => '7:00 م';

  @override
  String get medMarkAsTaken => 'تسجيل كمأخوذ';

  @override
  String get notifScreenTitle => 'الإشعارات';

  @override
  String get notifClearAll => 'مسح الكل';

  @override
  String get notifTabToday => 'اليوم';

  @override
  String get notifTabReminders => 'التذكيرات';

  @override
  String get notifTabEarlier => 'سابقًا';

  @override
  String get notifTitleMedicationTime => 'وقت الدواء';

  @override
  String notifDoseAt(Object time) {
    return 'جرعتك الساعة $time';
  }

  @override
  String get notifTitleMessageFromFamily => 'رسالة من العائلة';

  @override
  String get notifSubtitleFamilyPhoto => 'أرسلت سارة صورة جديدة!';

  @override
  String get motivationGreatTitle => 'أحسنت!';

  @override
  String get motivationGreatBody => 'أكملت 4 من 5 مهامك اليومية\nواصل على هذا المنوال!';

  @override
  String get familyScreenTitle => 'عائلتي';

  @override
  String get familyWhoCalling => 'من تريد الاتصال به؟';

  @override
  String get memoriesHeadingPrimary => 'ذكرياتنا';

  @override
  String get memoriesHeadingSecondary => '';

  @override
  String get memoriesViewPrimary => 'عرض';

  @override
  String get memoriesViewSecondary => 'الكل';

  @override
  String get memoryAlbumCaption => 'نزهة صيفية 2023\nحديقة البوابة الذهبية';

  @override
  String get memoriesAddNewMemory => 'إضافة ذكرى\nجديدة';

  @override
  String get familyMemberDetailTitle => 'فرد من العائلة';

  @override
  String get familySendMessage => 'إرسال رسالة';

  @override
  String get relationDaughter => 'ابنة';

  @override
  String get relationWife => 'زوجة';

  @override
  String get relationGrandson => 'حفيد';

  @override
  String callMember(Object name) {
    return 'اتصل بـ $name';
  }

  @override
  String familyMemberEncouragement(Object name) {
    return '$name على بُعد مكالمة فقط.\nيسعدهم سماعك.';
  }

  @override
  String get sosFabLabel => 'SOS';

  @override
  String get sosNeedHelpTitle => 'هل تحتاج إلى مساعدة؟';

  @override
  String get sosConfirmAssistanceBody => 'سنرسل مساعدة طارئة\nإلى موقعك فورًا.';

  @override
  String get sosYesSendHelp => 'نعم، أرسل المساعدة';

  @override
  String get sosSendingCardTitle => 'جاري إرسال SOS...';

  @override
  String get sosConnectingContactsLine => 'جاري الاتصال بسارة ميلر والدكتور أريس';

  @override
  String get sosViewEmergencyContacts => 'عرض جهات الطوارئ';

  @override
  String get sosAppBarEmergencySos => 'طوارئ SOS';

  @override
  String get sosHelpRequestSent => 'تم إرسال طلب المساعدة';

  @override
  String get sosContactingFamily => 'جاري التواصل مع عائلتك...';

  @override
  String get sosSendingGuidanceBody => 'نُنذر جهات الطوارئ الخاصة بك\nونُرسل موقعك الحالي.\nيرجى البقاء حيث أنت.';

  @override
  String get sosLabelCurrentLocation => 'الموقع الحالي';

  @override
  String get sosSampleAddress => '123 شارع المابل، شقة 4ب';

  @override
  String get sosLabelPrimaryContact => 'جهة الاتصال الأساسية';

  @override
  String get sosSamplePrimaryContact => 'سارة ميلر (ابنة)';

  @override
  String get sosCancelRequest => 'إلغاء الطلب';

  @override
  String get sosMistakeHint => 'إذا كان ذلك بالخطأ، اضغط أعلاه للإيقاف.';

  @override
  String get sosAppBarSosSent => 'تم إرسال SOS';

  @override
  String get sosSentSuccessTitle => 'تم إرسال طلب SOS\nبنجاح!';

  @override
  String get sosSentSuccessBody => 'تم إشعار عائلتك والمُعتنين.\nحافظ على هدوئك، المساعدة في الطريق.';

  @override
  String get sosLocationSharedTitle => 'تم مشاركة الموقع';

  @override
  String get sosLocationSharedBody => 'يمكن للمُعتنين رؤية\nموقعك الحالي.';

  @override
  String get sosBackToHome => 'العودة للرئيسية';

  @override
  String get sosCallEmergencyNumber => 'اتصل برقم الطوارئ';

  @override
  String get sosHelpEtaNote => 'تصل المساعدة عادة خلال 5–10 دقائق';

  @override
  String get sosSimulateSent => 'محاكاة الإرسال';

  @override
  String get sosSettingsScreenTitle => 'إعدادات SOS';

  @override
  String get sosEmergencyContactTitle => 'جهة طوارئ';

  @override
  String get sosPrimaryCaregiverSubtitle => 'المُعتنِي الأساسي بك';

  @override
  String get sosCaregiverNameLabel => 'اسم المُعتنِي';

  @override
  String get sosPhoneNumberLabel => 'رقم الهاتف';

  @override
  String get sosPlaceholderCaregiverName => 'سارة جونسون';

  @override
  String get sosPlaceholderPhone => '01255884562';

  @override
  String get sosCallEmergencyContact => 'اتصل بجهة الطوارئ';

  @override
  String get sosOptionsHeader => 'خيارات SOS';

  @override
  String get sosShareLocationTitle => 'مشاركة الموقع';

  @override
  String get sosShareLocationSubtitle => 'أرسل موقعك أثناء SOS';

  @override
  String get sosAutoCallTitle => 'اتصال تلقائي';

  @override
  String get sosAutoCallSubtitle => 'الاتصال تلقائيًا بجهات الطوارئ';

  @override
  String get sosTestSystemTitle => 'اختبار نظام SOS';

  @override
  String get sosTestSystemSubtitle => 'تحقق مما إذا كان نظام SOS\nيعمل بشكل صحيح';

  @override
  String get sosTestButton => 'اختبار SOS';

  @override
  String get sosHowItWorksTitle => 'كيف يعمل SOS';

  @override
  String get sosHowItWorksBullet1 => '• اضغط مع الاستمرار على زر SOS لمدة 3 ثوانٍ';

  @override
  String get sosHowItWorksBullet2 => '• يُشارك موقعك إذا كان مفعّلًا';

  @override
  String get sosHowItWorksBullet3 => '• يتم الاتصال بجهة الطوارئ تلقائيًا';

  @override
  String get doctorConnectTitle => 'الاتصال بالمريض';

  @override
  String get doctorConnectSubtitle => 'أدخل رمز المريض لطلب الوصول';

  @override
  String get doctorPatientIdLabel => 'معرّف المريض';

  @override
  String get doctorPatientIdHint => 'D-537254';

  @override
  String get doctorSubmitCodeButton => 'إرسال الرمز';

  @override
  String get doctorConnectInfoBody => 'اطلب الرمز من المريض. ستنتقل إلى الصفحة التالية بعد إدخاله.';

  @override
  String get doctorPrivacyNoticeBody => 'لحماية خصوصية المريض، يجب التحقق منك بواسطة المريض أو الوصي الأساسي قبل الوصول إلى السجلات الصحية.';

  @override
  String doctorPatientIdDisplay(Object id) {
    return 'المعرّف: $id';
  }

  @override
  String get doctorStatusPending => 'قيد الانتظار';

  @override
  String get doctorStatusWaitingTitle => 'حالة الانتظار';

  @override
  String get doctorStatusWaitingSubtitle => 'النظام يزامن السجلات المشفرة للمستخدمين الجدد.';

  @override
  String get doctorCheckAccessButton => 'التحقق من الوصول';

  @override
  String get doctorEmergencyRequestTitle => 'طلب طوارئ';

  @override
  String get doctorEmergencyRequestSubtitle => 'مارغريت طومسون\nمنذ دقيقتين';

  @override
  String get doctorCallButton => 'اتصال';

  @override
  String get doctorLocationButton => 'الموقع';

  @override
  String get doctorMessageButton => 'رسالة';

  @override
  String get doctorStatusStable => 'مستقر';

  @override
  String get doctorPatientProgressTitle => 'تقدم المريض';

  @override
  String get doctorWellnessScoreLine => 'درجة الرفاهية الإجمالية لهذا الأسبوع.';

  @override
  String doctorWellnessPercent(Object percent) {
    return '$percent٪';
  }

  @override
  String get doctorAlertsSectionTitle => 'تنبيهات';

  @override
  String doctorActiveAlertsCount(Object count) {
    return '$count نشطة';
  }

  @override
  String get doctorAlertMissedMedication => 'دواء فائت';

  @override
  String get doctorAlertActivityReminder => 'تذكير نشاط';

  @override
  String get doctorNextDoseLabel => 'الجرعة التالية';

  @override
  String get doctorNextDoseValue => 'أريسبت 10 مجم';

  @override
  String get doctorAddMedication => 'إضافة دواء';

  @override
  String get doctorTodaysProgressLabel => 'تقدم اليوم';

  @override
  String get doctorTodaysProgressDone => 'اكتمل روتين الصباح.';

  @override
  String get doctorMedViewAll => 'عرض الكل';

  @override
  String get doctorNextDoseSchedule => 'أريسبت 10 مجم - 8:00 م';

  @override
  String get doctorNextDoseIn => 'خلال ساعتين';

  @override
  String get doctorActivitiesTitle => 'الأنشطة';

  @override
  String doctorActivitiesCompletedCount(Object count) {
    return '$count مكتملة';
  }

  @override
  String get doctorAlertMissedMedDetail => 'جرعة المساء - أريسبت 10 مجم';

  @override
  String get doctorAlertMissedMedOverdue => 'متأخر ساعتان';

  @override
  String get doctorAlertActivityDetail => 'تمرين الذاكرة قيد الانتظار';

  @override
  String get doctorAlertActivityDue => 'مستحق خلال 30 دقيقة';

  @override
  String doctorFamilyAccessLine(Object count) {
    return '$count أعضاء لديهم وصول';
  }

  @override
  String get doctorAssignActivity => 'تعيين نشاط';

  @override
  String get doctorFamilyMembersTitle => 'أفراد العائلة';

  @override
  String get doctorManageFamily => 'إدارة العائلة';

  @override
  String doctorPatientAgeRoom(Object age, Object room) {
    return 'العمر $age · الغرفة $room';
  }

  @override
  String get doctorFloatingChat => 'محادثة';

  @override
  String get doctorFloatingCall => 'اتصال بالمريض';

  @override
  String get doctorPatientIdRequired => 'يرجى إدخال معرّف المريض.';

  @override
  String get doctorPatientNotFound => 'لا يوجد مريض بهذا المعرّف. تحقق من الرمز وحاول مرة أخرى.';

  @override
  String get doctorPatientLookupError => 'تعذّر البحث عن المريض. تحقق من الاتصال وحاول مرة أخرى.';

  @override
  String get doctorLinkRequestFailed => 'تعذّر إرسال الطلب. تحقق من الاتصال أو حاول لاحقًا.';

  @override
  String get doctorPendingWaitForPatient => 'ستتحدّث هذه الشاشة تلقائيًا عندما يقبل المريض طلبك.';

  @override
  String get doctorProfileQuickInfoTitle => 'معلومات سريعة';

  @override
  String get doctorProfileLinkedPatientTitle => 'المريض المرتبط';

  @override
  String get doctorProfileNotLinkedPatient => 'لا يوجد مريض مرتبط بعد';

  @override
  String get doctorProfileManagedTasksTitle => 'المهام المُدارة';

  @override
  String doctorProfileManagedTasksSubtitle(Object count) {
    return '$count مهام نشطة';
  }

  @override
  String get doctorProfileCaregiverRole => 'مقدّم رعاية';

  @override
  String get doctorProfileSosSettingsTitle => 'إعدادات الطوارئ';

  @override
  String get doctorProfileEditProfileTooltip => 'تعديل الملف';

  @override
  String get doctorMedConnectFirst => 'اربط مريضًا أولًا لإدارة الأدوية.';

  @override
  String get doctorMedTitleMedication => 'الدواء';

  @override
  String get doctorMedViewDetails => 'عرض التفاصيل';

  @override
  String get doctorMedAllGoodToday => 'كل شيء جيد اليوم';

  @override
  String get doctorMedRequiresAttention => 'تحتاج متابعة';

  @override
  String doctorMedDosesMissedToday(Object count) {
    return '$count جرعات فائتة اليوم';
  }

  @override
  String get doctorMedTotalMedication => 'إجمالي الأدوية';

  @override
  String get doctorMedTakenToday => 'المأخوذ اليوم';

  @override
  String get doctorMedMissed => 'فائت';

  @override
  String get doctorMedTodaySchedule => 'جدول اليوم';

  @override
  String get doctorMedNoMedicationYet => 'لا توجد أدوية بعد.';

  @override
  String get doctorMedAllMedications => 'كل الأدوية';

  @override
  String get doctorMedAddMedication => 'إضافة دواء';

  @override
  String get doctorMedMedicationDetailsButton => 'تفاصيل الأدوية';

  @override
  String doctorMedNextAt(Object time) {
    return 'التالي: $time';
  }

  @override
  String get doctorMedStatusTaken => 'مأخوذ';

  @override
  String get doctorMedStatusMissed => 'فائت';

  @override
  String get doctorMedStatusUpcoming => 'قادم';

  @override
  String get doctorMedDeleteTitle => 'حذف الدواء؟';

  @override
  String get doctorMedDeleteBody => 'لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get doctorMedDeleteButton => 'حذف';

  @override
  String get doctorMedDeleteFailed => 'تعذّر حذف الدواء.';

  @override
  String get doctorMedFrequencyLabel => 'التكرار';

  @override
  String get doctorMedInstructionsTitle => 'التعليمات';

  @override
  String get doctorMedNoInstructions => 'لا توجد تعليمات من مقدم الرعاية.';

  @override
  String get doctorMedEditMedication => 'تعديل الدواء';

  @override
  String get doctorMedDeleteMedication => 'حذف الدواء';

  @override
  String get doctorMedSaveChanges => 'حفظ التغييرات';

  @override
  String get doctorMedSaveMedication => 'حفظ الدواء';

  @override
  String get doctorMedCouldNotSave => 'تعذّر حفظ الدواء الآن.';

  @override
  String get doctorMedCouldNotSaveChanges => 'تعذّر حفظ التغييرات الآن.';

  @override
  String get doctorMedMedicationNameRequired => 'اسم الدواء مطلوب.';

  @override
  String get doctorMedMedicationName => 'اسم الدواء';

  @override
  String get doctorMedWhatTime => 'في أي وقت؟';

  @override
  String get doctorMedPrimaryTime => 'الوقت الأساسي';

  @override
  String get doctorMedSecondTime => 'الوقت الثاني';

  @override
  String get doctorMedThirdTime => 'الوقت الثالث';

  @override
  String get doctorMedSetTime => 'تحديد الوقت';

  @override
  String get doctorMedHowOften => 'عدد المرات';

  @override
  String get doctorMedOnceDaily => 'مرة يوميًا';

  @override
  String get doctorMedTwiceDaily => 'مرتين يوميًا';

  @override
  String get doctorMedThreeDaily => '3 مرات يوميًا';

  @override
  String get doctorMedNumberOfDays => 'عدد الأيام';

  @override
  String get doctorMedDaysTotal => 'إجمالي الأيام';

  @override
  String get doctorMedMedicineType => 'نوع الدواء';

  @override
  String get doctorMedTypeTablet => 'أقراص';

  @override
  String get doctorMedTypeSyringe => 'حقنة';

  @override
  String get doctorMedTypeDrink => 'مشروب';

  @override
  String get doctorMedDose => 'الجرعة';

  @override
  String get doctorMedSelectMlAmount => 'اختر كمية المل';

  @override
  String get doctorMedDone => 'تم';

  @override
  String get doctorMedCaregiverInstructions => 'تعليمات مقدم الرعاية';

  @override
  String get doctorMedInstructionHint => 'مثال: يُعطى مع وجبة خفيفة.\nقد يقاوم المريض إذا كانت الغرفة شديدة الإضاءة.';

  @override
  String get doctorMedStepOneOfTwo => 'الخطوة 1 من 2';

  @override
  String get doctorMedNewPrescription => 'وصفة جديدة';

  @override
  String get doctorMedDuration => 'المدة';

  @override
  String get doctorMedMedicationDetailsHeader => 'تفاصيل الدواء';

  @override
  String get doctorMedUnitTabletSingular => 'قرص';

  @override
  String get doctorMedUnitTabletPlural => 'أقراص';

  @override
  String get doctorMedUnitMl => 'مل';
}
