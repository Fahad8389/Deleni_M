// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Delni';

  @override
  String get appTagline => 'Hospital Indoor Navigation';

  @override
  String get home => 'Home';

  @override
  String get back => 'Back';

  @override
  String get searchClinics => 'Search Clinics';

  @override
  String get searchClinicsDesc => 'Find and navigate to clinics';

  @override
  String get visitPatient => 'Visit Patient';

  @override
  String get visitPatientDesc => 'Navigate to patient rooms';

  @override
  String get myAppointments => 'My Appointments';

  @override
  String get myAppointmentsDesc => 'Manage your appointments';

  @override
  String get emergency => 'Emergency';

  @override
  String get emergencyDesc => 'Quick route to ER';

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get darkModeDesc => 'Switch to dark theme';

  @override
  String get languageRegion => 'Language & Region';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get accessibility => 'Accessibility';

  @override
  String get accessibilityMode => 'Accessibility Mode';

  @override
  String get accessibilityModeDesc => 'Larger text and enhanced paths';

  @override
  String get accessibilityEnabled => 'Accessibility mode is enabled';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsDesc => 'Receive appointment reminders';

  @override
  String get about => 'About';

  @override
  String get aboutDesc =>
      'Delni helps you navigate hospitals in Saudi Arabia with ease. Find clinics, visit patients, and manage appointments.';

  @override
  String get version => 'Version';

  @override
  String get madeWith => 'Made with care for better hospital navigation';

  @override
  String get searchDestination => 'Search for a destination...';

  @override
  String get noResults => 'No results found';

  @override
  String get floor => 'Floor';

  @override
  String get groundFloor => 'Ground Floor';

  @override
  String get firstFloor => 'First Floor';

  @override
  String get secondFloor => 'Second Floor';

  @override
  String get selectHospital => 'Select Hospital';

  @override
  String get destinations => 'Destinations';

  @override
  String get clinic => 'Clinic';

  @override
  String get department => 'Department';

  @override
  String get room => 'Room';

  @override
  String get emergencyDept => 'Emergency';

  @override
  String get distance => 'Distance';

  @override
  String get meters => 'm';

  @override
  String get walkingTime => 'Walking Time';

  @override
  String get minutes => 'min';

  @override
  String navigateTo(String name) {
    return 'Navigate to $name';
  }

  @override
  String get enterRoomNumber => 'Enter room number';

  @override
  String get findRoom => 'Find Room';

  @override
  String get roomNotFound => 'Room not found. Please check the number.';

  @override
  String get searchAgain => 'Search Again';

  @override
  String get quickAccess => 'Quick Access';

  @override
  String navigatingTo(String name) {
    return 'Navigating to $name';
  }

  @override
  String get createAppointment => 'Create Appointment';

  @override
  String get noAppointments => 'No appointments yet';

  @override
  String get noAppointmentsDesc =>
      'Create your first appointment to get started';

  @override
  String get selectClinic => 'Select a clinic';

  @override
  String get selectDate => 'Select date';

  @override
  String get selectTime => 'Select a time slot';

  @override
  String get available => 'Available';

  @override
  String get limited => 'Limited';

  @override
  String get full => 'Full';

  @override
  String remaining(int count) {
    return '$count remaining';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get navigateToClinic => 'Navigate to Clinic';

  @override
  String startsIn(String time) {
    return 'Starts in: $time';
  }

  @override
  String get appointmentPassed => 'Appointment passed';

  @override
  String get emergencyMode => 'EMERGENCY MODE';

  @override
  String get emergencyRouteInfo =>
      'Follow the highlighted path to the Emergency Department';

  @override
  String get call997 => 'Call 997';

  @override
  String get emergencyContact => 'Saudi Emergency Services';

  @override
  String get emergencyInstructions => 'Emergency Instructions';

  @override
  String get instruction1 => 'Follow the red highlighted path';

  @override
  String get instruction2 => 'Look for emergency signs with red cross';

  @override
  String get instruction3 => 'Ask hospital staff for assistance';

  @override
  String get emergencyWarning =>
      'In case of a life-threatening emergency, call 997 immediately. Navigation is for guidance only.';

  @override
  String get startNavigation => 'Start Navigation';

  @override
  String get endNavigation => 'End Navigation';

  @override
  String roomLabel(String number) {
    return 'Room $number';
  }

  @override
  String floorLabel(int number) {
    return 'Floor $number';
  }

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';
}
