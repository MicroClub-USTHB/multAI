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
}
