// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'دلني';

  @override
  String get appTagline => 'الملاحة الداخلية للمستشفى';

  @override
  String get home => 'الرئيسية';

  @override
  String get back => 'رجوع';

  @override
  String get searchClinics => 'البحث عن العيادات';

  @override
  String get searchClinicsDesc => 'ابحث وتنقل إلى العيادات';

  @override
  String get visitPatient => 'زيارة مريض';

  @override
  String get visitPatientDesc => 'انتقل إلى غرف المرضى';

  @override
  String get myAppointments => 'مواعيدي';

  @override
  String get myAppointmentsDesc => 'إدارة مواعيدك';

  @override
  String get emergency => 'الطوارئ';

  @override
  String get emergencyDesc => 'طريق سريع إلى الطوارئ';

  @override
  String get settings => 'الإعدادات';

  @override
  String get appearance => 'المظهر';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get darkModeDesc => 'التبديل إلى المظهر الداكن';

  @override
  String get languageRegion => 'اللغة والمنطقة';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get accessibility => 'إمكانية الوصول';

  @override
  String get accessibilityMode => 'وضع إمكانية الوصول';

  @override
  String get accessibilityModeDesc => 'نص أكبر ومسارات محسنة';

  @override
  String get accessibilityEnabled => 'تم تفعيل وضع إمكانية الوصول';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get notificationsDesc => 'تلقي تذكيرات المواعيد';

  @override
  String get about => 'حول التطبيق';

  @override
  String get aboutDesc =>
      'دلني يساعدك على التنقل في المستشفيات في المملكة العربية السعودية بسهولة. ابحث عن العيادات، قم بزيارة المرضى، وأدر مواعيدك.';

  @override
  String get version => 'الإصدار';

  @override
  String get madeWith => 'صُنع بعناية لتحسين الملاحة في المستشفيات';

  @override
  String get searchDestination => 'ابحث عن وجهة...';

  @override
  String get noResults => 'لا توجد نتائج';

  @override
  String get floor => 'الطابق';

  @override
  String get groundFloor => 'الطابق الأرضي';

  @override
  String get firstFloor => 'الطابق الأول';

  @override
  String get secondFloor => 'الطابق الثاني';

  @override
  String get selectHospital => 'اختر المستشفى';

  @override
  String get destinations => 'الوجهات';

  @override
  String get clinic => 'عيادة';

  @override
  String get department => 'قسم';

  @override
  String get room => 'غرفة';

  @override
  String get emergencyDept => 'الطوارئ';

  @override
  String get distance => 'المسافة';

  @override
  String get meters => 'م';

  @override
  String get walkingTime => 'وقت المشي';

  @override
  String get minutes => 'دقيقة';

  @override
  String navigateTo(String name) {
    return 'انتقل إلى $name';
  }

  @override
  String get enterRoomNumber => 'أدخل رقم الغرفة';

  @override
  String get findRoom => 'البحث عن الغرفة';

  @override
  String get roomNotFound => 'الغرفة غير موجودة. يرجى التحقق من الرقم.';

  @override
  String get searchAgain => 'البحث مرة أخرى';

  @override
  String get quickAccess => 'وصول سريع';

  @override
  String navigatingTo(String name) {
    return 'التنقل إلى $name';
  }

  @override
  String get createAppointment => 'إنشاء موعد';

  @override
  String get noAppointments => 'لا توجد مواعيد بعد';

  @override
  String get noAppointmentsDesc => 'أنشئ أول موعد لك للبدء';

  @override
  String get selectClinic => 'اختر عيادة';

  @override
  String get selectDate => 'اختر التاريخ';

  @override
  String get selectTime => 'اختر وقتاً';

  @override
  String get available => 'متاح';

  @override
  String get limited => 'محدود';

  @override
  String get full => 'ممتلئ';

  @override
  String remaining(int count) {
    return '$count متبقي';
  }

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get navigateToClinic => 'انتقل إلى العيادة';

  @override
  String startsIn(String time) {
    return 'يبدأ في: $time';
  }

  @override
  String get appointmentPassed => 'انتهى الموعد';

  @override
  String get emergencyMode => 'وضع الطوارئ';

  @override
  String get emergencyRouteInfo => 'اتبع المسار المميز إلى قسم الطوارئ';

  @override
  String get call997 => 'اتصل ٩٩٧';

  @override
  String get emergencyContact => 'خدمات الطوارئ السعودية';

  @override
  String get emergencyInstructions => 'تعليمات الطوارئ';

  @override
  String get instruction1 => 'اتبع المسار الأحمر المميز';

  @override
  String get instruction2 => 'ابحث عن لافتات الطوارئ بالصليب الأحمر';

  @override
  String get instruction3 => 'اطلب المساعدة من موظفي المستشفى';

  @override
  String get emergencyWarning =>
      'في حالة الطوارئ المهددة للحياة، اتصل بـ ٩٩٧ فوراً. الملاحة للإرشاد فقط.';

  @override
  String get startNavigation => 'بدء الملاحة';

  @override
  String get endNavigation => 'إنهاء الملاحة';

  @override
  String roomLabel(String number) {
    return 'غرفة $number';
  }

  @override
  String floorLabel(int number) {
    return 'الطابق $number';
  }

  @override
  String get today => 'اليوم';

  @override
  String get tomorrow => 'غداً';
}
