// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get theme => 'المظهر';

  @override
  String get languages => 'اللغات';

  @override
  String get chooseYourLanguage => 'اختر لغتك';

  @override
  String get english => 'الإنجليزية';

  @override
  String get french => 'الفرنسية';

  @override
  String get arabic => 'العربية';

  @override
  String get editName => 'تعديل الاسم';

  @override
  String get yourName => 'اسمك';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get clearImageCache => 'مسح ذاكرة التخزين المؤقت للصور';

  @override
  String get clearImageCacheDescription =>
      'سيؤدي هذا إلى إزالة جميع الصور المخزنة مؤقتًا من جهازك. ستحتاج الصور إلى إعادة تنزيلها عند عرضها مرة أخرى.';

  @override
  String get clear => 'مسح';

  @override
  String get freeUpStorage => 'تحرير مساحة التخزين';

  @override
  String get clearingCache => 'جارٍ مسح ذاكرة التخزين المؤقت...';

  @override
  String freedStorage(Object storage, Object files) {
    return 'تم تحرير $storage ($files ملفات)';
  }

  @override
  String get light => 'فاتح';

  @override
  String get dark => 'داكن';

  @override
  String get systemDefault => 'إعداد النظام';

  @override
  String get chooseTheme => 'اختر مظهرًا فاتحًا أو داكنًا';

  @override
  String get accountSettings => 'إعدادات الحساب';

  @override
  String get privacySecurity => 'الخصوصية والأمان';

  @override
  String get privacySecurityDescription =>
      'كلمة المرور والمصادقة الثنائية ومشاركة البيانات';

  @override
  String get support => 'الدعم';

  @override
  String get helpCenter => 'مركز المساعدة';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get deleteAccountConfirmation =>
      'هل أنت متأكد أنك تريد حذف هذا الحساب؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get home => 'الرئيسية';

  @override
  String get gallery => 'المعرض';

  @override
  String get event => 'الفعالية';

  @override
  String get account => 'الحساب';

  @override
  String get eventsTitle => 'فعاليات MultiAi';

  @override
  String get eventJoinedSuccess => 'تم الانضمام إلى الفعالية بنجاح!';

  @override
  String get cachedDataMessage =>
      'يتم عرض البيانات المخزنة مؤقتًا. اتصل بالإنترنت لرؤية أحدث البيانات.';

  @override
  String get joinNewEvent => 'الانضمام إلى فعالية جديدة';

  @override
  String get joinEventDescription =>
      'لديك دعوة؟ أدخل رمز الفعالية أدناه للمشاركة.';

  @override
  String get scanQrCode => 'مسح رمز QR';

  @override
  String get joinEvent => 'الانضمام إلى الفعالية';

  @override
  String get activeEvents => 'الفعاليات النشطة';

  @override
  String ongoingEvents(Object count) {
    return '$count جارية';
  }

  @override
  String get noActiveEvents => 'لا توجد فعاليات نشطة';

  @override
  String get joinEventToSeeHere => 'انضم إلى فعالية لرؤيتها هنا!';

  @override
  String get archivedEvents => 'الفعاليات المؤرشفة';

  @override
  String get noArchivedEvents => 'لا توجد فعاليات مؤرشفة';

  @override
  String get archivedEventsEmpty => 'ستظهر فعالياتك المؤرشفة هنا.';

  @override
  String get galleryTitle => 'المعرض';

  @override
  String get allPhotos => 'الكل';

  @override
  String get soloPhotos => 'فردية';

  @override
  String get groupPhotos => 'جماعية';

  @override
  String get noPhotosYet => 'لا توجد صور بعد';

  @override
  String get yourEvents => 'فعالياتك';

  @override
  String get scanEventQrCode => 'مسح رمز QR للفعالية';

  @override
  String get camera => 'الكاميرا';

  @override
  String get galleryPicker => 'المعرض';

  @override
  String get previous => 'السابق';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get noEventsYet => 'لا توجد فعاليات بعد';

  @override
  String get pointCameraAtQrCode => 'وجّه الكاميرا نحو رمز QR الخاص بالفعالية';

  @override
  String get skipOptionalPhotos => 'تخطي الصور الاختيارية';

  @override
  String get skip => 'تخطي';

  @override
  String get completeEnrollment => 'إكمال التسجيل';

  @override
  String get uploadRequiredPhotosFirst => 'قم بتحميل الصور المطلوبة أولًا';

  @override
  String get nextStep => 'الخطوة التالية';

  @override
  String get complete => 'إكمال';

  @override
  String get uploadRequired => 'التحميل مطلوب';

  @override
  String get next => 'التالي';

  @override
  String get securityAlert => 'تنبيه أمني';

  @override
  String get noInternetConnection => 'لا يوجد اتصال بالإنترنت';

  @override
  String get checkConnectionAndRetry =>
      'يُرجى التحقق من اتصالك والمحاولة مرة أخرى.';

  @override
  String get previousStep => 'الخطوة السابقة';

  @override
  String get preferences => 'التفضيلات';

  @override
  String get appearance => 'المظهر';

  @override
  String get lightDarkMode => 'الوضع الفاتح / الداكن';

  @override
  String get language => 'اللغة';

  @override
  String get changeAppLanguage => 'تغيير لغة التطبيق';

  @override
  String get selectTheme => 'اختر المظهر';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get manageAlertsAndActivity => 'إدارة التنبيهات والنشاط';

  @override
  String get backupPhotos => 'نسخ الصور احتياطيًا';

  @override
  String get downloadPhotosAsZip => 'تنزيل جميع الصور كملف ZIP';

  @override
  String get myAlbums => 'ألبوماتي';

  @override
  String get organizePhotosIntoAlbums => 'تنظيم الصور في ألبومات';

  @override
  String get mcMember => 'عضو mc';

  @override
  String get changeProfilePhoto => 'تغيير صورة الملف الشخصي';

  @override
  String get photoUpdateFailed => 'تعذر تحديث صورتك. حاول مرة أخرى.';
}
