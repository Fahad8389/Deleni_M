import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Delni'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Hospital Indoor Navigation'**
  String get appTagline;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @searchClinics.
  ///
  /// In en, this message translates to:
  /// **'Search Clinics'**
  String get searchClinics;

  /// No description provided for @searchClinicsDesc.
  ///
  /// In en, this message translates to:
  /// **'Find and navigate to clinics'**
  String get searchClinicsDesc;

  /// No description provided for @visitPatient.
  ///
  /// In en, this message translates to:
  /// **'Visit Patient'**
  String get visitPatient;

  /// No description provided for @visitPatientDesc.
  ///
  /// In en, this message translates to:
  /// **'Navigate to patient rooms'**
  String get visitPatientDesc;

  /// No description provided for @myAppointments.
  ///
  /// In en, this message translates to:
  /// **'My Appointments'**
  String get myAppointments;

  /// No description provided for @myAppointmentsDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage your appointments'**
  String get myAppointmentsDesc;

  /// No description provided for @emergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergency;

  /// No description provided for @emergencyDesc.
  ///
  /// In en, this message translates to:
  /// **'Quick route to ER'**
  String get emergencyDesc;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @darkModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Switch to dark theme'**
  String get darkModeDesc;

  /// No description provided for @languageRegion.
  ///
  /// In en, this message translates to:
  /// **'Language & Region'**
  String get languageRegion;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @accessibility.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get accessibility;

  /// No description provided for @accessibilityMode.
  ///
  /// In en, this message translates to:
  /// **'Accessibility Mode'**
  String get accessibilityMode;

  /// No description provided for @accessibilityModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Larger text and enhanced paths'**
  String get accessibilityModeDesc;

  /// No description provided for @accessibilityEnabled.
  ///
  /// In en, this message translates to:
  /// **'Accessibility mode is enabled'**
  String get accessibilityEnabled;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive appointment reminders'**
  String get notificationsDesc;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutDesc.
  ///
  /// In en, this message translates to:
  /// **'Delni helps you navigate hospitals in Saudi Arabia with ease. Find clinics, visit patients, and manage appointments.'**
  String get aboutDesc;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @madeWith.
  ///
  /// In en, this message translates to:
  /// **'Made with care for better hospital navigation'**
  String get madeWith;

  /// No description provided for @searchDestination.
  ///
  /// In en, this message translates to:
  /// **'Search for a destination...'**
  String get searchDestination;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @floor.
  ///
  /// In en, this message translates to:
  /// **'Floor'**
  String get floor;

  /// No description provided for @groundFloor.
  ///
  /// In en, this message translates to:
  /// **'Ground Floor'**
  String get groundFloor;

  /// No description provided for @firstFloor.
  ///
  /// In en, this message translates to:
  /// **'First Floor'**
  String get firstFloor;

  /// No description provided for @secondFloor.
  ///
  /// In en, this message translates to:
  /// **'Second Floor'**
  String get secondFloor;

  /// No description provided for @selectHospital.
  ///
  /// In en, this message translates to:
  /// **'Select Hospital'**
  String get selectHospital;

  /// No description provided for @destinations.
  ///
  /// In en, this message translates to:
  /// **'Destinations'**
  String get destinations;

  /// No description provided for @clinic.
  ///
  /// In en, this message translates to:
  /// **'Clinic'**
  String get clinic;

  /// No description provided for @department.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get department;

  /// No description provided for @room.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get room;

  /// No description provided for @emergencyDept.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergencyDept;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @meters.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get meters;

  /// No description provided for @walkingTime.
  ///
  /// In en, this message translates to:
  /// **'Walking Time'**
  String get walkingTime;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutes;

  /// No description provided for @navigateTo.
  ///
  /// In en, this message translates to:
  /// **'Navigate to {name}'**
  String navigateTo(String name);

  /// No description provided for @enterRoomNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter room number'**
  String get enterRoomNumber;

  /// No description provided for @findRoom.
  ///
  /// In en, this message translates to:
  /// **'Find Room'**
  String get findRoom;

  /// No description provided for @roomNotFound.
  ///
  /// In en, this message translates to:
  /// **'Room not found. Please check the number.'**
  String get roomNotFound;

  /// No description provided for @searchAgain.
  ///
  /// In en, this message translates to:
  /// **'Search Again'**
  String get searchAgain;

  /// No description provided for @quickAccess.
  ///
  /// In en, this message translates to:
  /// **'Quick Access'**
  String get quickAccess;

  /// No description provided for @navigatingTo.
  ///
  /// In en, this message translates to:
  /// **'Navigating to {name}'**
  String navigatingTo(String name);

  /// No description provided for @createAppointment.
  ///
  /// In en, this message translates to:
  /// **'Create Appointment'**
  String get createAppointment;

  /// No description provided for @noAppointments.
  ///
  /// In en, this message translates to:
  /// **'No appointments yet'**
  String get noAppointments;

  /// No description provided for @noAppointmentsDesc.
  ///
  /// In en, this message translates to:
  /// **'Create your first appointment to get started'**
  String get noAppointmentsDesc;

  /// No description provided for @selectClinic.
  ///
  /// In en, this message translates to:
  /// **'Select a clinic'**
  String get selectClinic;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select a time slot'**
  String get selectTime;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @limited.
  ///
  /// In en, this message translates to:
  /// **'Limited'**
  String get limited;

  /// No description provided for @full.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get full;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'{count} remaining'**
  String remaining(int count);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @navigateToClinic.
  ///
  /// In en, this message translates to:
  /// **'Navigate to Clinic'**
  String get navigateToClinic;

  /// No description provided for @startsIn.
  ///
  /// In en, this message translates to:
  /// **'Starts in: {time}'**
  String startsIn(String time);

  /// No description provided for @appointmentPassed.
  ///
  /// In en, this message translates to:
  /// **'Appointment passed'**
  String get appointmentPassed;

  /// No description provided for @emergencyMode.
  ///
  /// In en, this message translates to:
  /// **'EMERGENCY MODE'**
  String get emergencyMode;

  /// No description provided for @emergencyRouteInfo.
  ///
  /// In en, this message translates to:
  /// **'Follow the highlighted path to the Emergency Department'**
  String get emergencyRouteInfo;

  /// No description provided for @call997.
  ///
  /// In en, this message translates to:
  /// **'Call 997'**
  String get call997;

  /// No description provided for @emergencyContact.
  ///
  /// In en, this message translates to:
  /// **'Saudi Emergency Services'**
  String get emergencyContact;

  /// No description provided for @emergencyInstructions.
  ///
  /// In en, this message translates to:
  /// **'Emergency Instructions'**
  String get emergencyInstructions;

  /// No description provided for @instruction1.
  ///
  /// In en, this message translates to:
  /// **'Follow the red highlighted path'**
  String get instruction1;

  /// No description provided for @instruction2.
  ///
  /// In en, this message translates to:
  /// **'Look for emergency signs with red cross'**
  String get instruction2;

  /// No description provided for @instruction3.
  ///
  /// In en, this message translates to:
  /// **'Ask hospital staff for assistance'**
  String get instruction3;

  /// No description provided for @emergencyWarning.
  ///
  /// In en, this message translates to:
  /// **'In case of a life-threatening emergency, call 997 immediately. Navigation is for guidance only.'**
  String get emergencyWarning;

  /// No description provided for @startNavigation.
  ///
  /// In en, this message translates to:
  /// **'Start Navigation'**
  String get startNavigation;

  /// No description provided for @endNavigation.
  ///
  /// In en, this message translates to:
  /// **'End Navigation'**
  String get endNavigation;

  /// No description provided for @roomLabel.
  ///
  /// In en, this message translates to:
  /// **'Room {number}'**
  String roomLabel(String number);

  /// No description provided for @floorLabel.
  ///
  /// In en, this message translates to:
  /// **'Floor {number}'**
  String floorLabel(int number);

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
