# Delni App — Project Context

## Overview
Delni (دلني) is a hospital indoor navigation app for Saudi Arabian hospitals, built with Flutter. It was ported from a React/TypeScript web prototype at `/Users/fahd838/Downloads/Hospital Indoor Navigation App/`. The app supports English and Arabic (RTL), dark mode, accessibility mode, and targets **iPhone (iOS)** as the primary platform.

## Design Direction: "Desert Wayfinder"
Inspired by Saudi Arabia's landscape and wayfinding through vast spaces.

| Role | Color | Hex |
|------|-------|-----|
| Primary (actions, nav paths) | Deep Teal | `#0D7377` |
| Background (light) | Warm Sand | `#F5E6D3` |
| Surface (light) | Alabaster | `#FAFAF5` |
| Emergency/destructive | Terracotta | `#C75B39` |
| Success/appointments | Date Palm Green | `#2D6A4F` |
| Accessibility paths | Gold | `#D4A843` |
| Dark mode base | Midnight Indigo | `#1B1F3B` |
| Dark mode surface | Dark Surface | `#252A4A` |

**Font:** Readex Pro (Google Fonts) — designed for Latin + Arabic in one family.
**Motifs:** 16-20px rounded corners, warm-tinted shadows, compass rose entrance markers.

## Tech Stack

| Concern | Package |
|---------|---------|
| State management | `flutter_riverpod` |
| Navigation | `go_router` |
| Local DB (appointments) | `hive_ce` + `hive_ce_flutter` |
| Settings persistence | `shared_preferences` |
| i18n | Custom `AppLocalizations` class (no codegen) + `flutter_localizations` + `intl` |
| Fonts | `google_fonts` (Readex Pro) |
| UUID | `uuid` |
| Floor plans + paths | `CustomPaint` (no external packages) |

## Project Structure

```
lib/
  main.dart                          # Entry point, Hive init, ProviderScope
  app.dart                           # MaterialApp.router, theme/locale binding
  core/
    theme/
      app_colors.dart                # Desert Wayfinder color palette
      app_theme.dart                 # Light + dark ThemeData (Material 3)
      app_typography.dart            # Readex Pro text theme
    l10n/
      app_localizations.dart         # Custom inline localization class (~80+ strings EN/AR)
      l10n_utils.dart                # Arabic numerals, localized date/time, RTL helpers
    router/
      app_router.dart                # GoRouter: 6 routes with custom transitions
    constants/
      app_constants.dart             # Walking speed, animation durations, version
  data/
    models/
      hospital.dart                  # Hospital, Floor, Destination, Position, LocaleString, DestinationType
      appointment.dart               # Hive-serializable Appointment + hand-written TypeAdapter
      time_slot.dart                 # TimeSlot, ClinicSchedule, SlotStatus enum
    repositories/
      hospital_repository.dart       # Hospital lookup, room search
      appointment_repository.dart    # Hive CRUD for appointments
      settings_repository.dart       # SharedPreferences wrapper
      schedule_repository.dart       # Clinic schedule lookup
    datasources/
      hospital_data.dart             # Hardcoded: 2 hospitals, 6 floors, ~17 destinations
      schedule_data.dart             # 14 clinic schedules with time slots
  providers/
    settings_provider.dart           # Language, darkMode, accessibilityMode, notifications, defaultHospitalId
    hospital_provider.dart           # Selected hospital/floor/destination state
    navigation_provider.dart         # RouteInfo calculation (distance, walk time)
    appointment_provider.dart        # AsyncNotifier with Hive persistence
    search_provider.dart             # Search query + filtered destinations
  features/
    home/
      home_screen.dart               # 4 feature cards, quick toggles, hospital chip
      widgets/feature_card.dart      # Reusable feature card
    map/
      map_screen.dart                # Search bar, floor tabs, hospital dropdown, navigation map
      painters/
        navigation_path_painter.dart # Animated path with corridor waypoints, arrows, pulse
    visitor/
      visitor_screen.dart            # Room number input, quick access chips, auto floor switch
    appointments/
      appointments_screen.dart       # Card grid, countdown timers, navigate-to-clinic
      widgets/
        create_appointment_sheet.dart # Bottom sheet: hospital/clinic/date/time slot selection
        appointment_card.dart        # Card with countdown Timer.periodic, navigate/delete
    emergency/
      emergency_screen.dart          # Terracotta theme, pulsing icon, call 997, sticky nav
    settings/
      settings_screen.dart           # Hospital selector, dark mode, language, accessibility, about
  shared/
    widgets/
      navigation_map_widget.dart     # Shared map widget (Map, Visitor, Emergency screens)
      accessibility_banner.dart      # Gold banner when accessibility enabled
      back_button.dart               # Reusable back navigation
    painters/
      floor_plan_painter.dart        # Re-exports factory from floor_plans/
      floor_plans/
        floor_plan_painter.dart      # Factory: returns correct painter for hospital+floor
        kf_ground.dart               # King Faisal Ground Floor
        kf_first.dart                # King Faisal First Floor
        kf_second.dart               # King Faisal Second Floor
        rc_ground.dart               # Riyadh Care Ground Floor
        rc_first.dart                # Riyadh Care First Floor
        rc_second.dart               # Riyadh Care Second Floor
  assets/
    l10n/
      app_en.arb                     # English ARB (70+ strings)
      app_ar.arb                     # Arabic ARB (70+ strings)
```

## Hospitals Data

### King Faisal Specialist Hospital (kf)
- Ground Floor: Main Entrance, Emergency, General Clinic, Radiology, Pharmacy, Reception, Cardiology, Room 101
- First Floor: Orthopedics, Pediatrics, Dental, Lab, Room 201
- Second Floor: Eye Clinic, ENT, Neurology, Room 301

### Riyadh Care Hospital (rc)
- Ground Floor: Main Entrance, Emergency, Family Medicine, Pharmacy
- First Floor: Dermatology
- Second Floor: (minimal destinations)

## Key Architecture Decisions

1. **No codegen l10n**: `AppLocalizations` is a plain Dart class with `_t(en, ar)` helper. No ARB codegen pipeline. Screens import from `core/l10n/app_localizations.dart`.

2. **app.dart does NOT include AppLocalizations.delegate** in localizationsDelegates — only GlobalMaterial/Widgets/Cupertino delegates. The custom AppLocalizations is instantiated manually via `AppLocalizations(settings.language)` wherever needed.

3. **Floor plan coordinate system**: Percentage-based (0-100) scaled to canvas size. All painters take `darkMode` and `locale` parameters.

4. **Navigation paths**: Corridor-following waypoints (not straight lines). Progressive reveal via `Path.computeMetrics().extractPath()`. Path colors: teal (normal), terracotta (emergency), gold (accessibility).

5. **Hive for appointments**: Hand-written TypeAdapter (no build_runner needed for Hive generation). Box name: `appointments`.

6. **NavigationMapWidget**: Shared by MapScreen, VisitorScreen, EmergencyScreen. Parameters include `destination`, `initialDestination`, `isEmergency`, `showSearchBar`, `height`.

## Known Issues & Optimization Opportunities

### Build Status
- **0 compile errors** — app builds and runs
- **94 info-level warnings** — mostly linting suggestions (prefer_const_constructors, unnecessary_this, etc.)
- Successfully runs on Chrome (`flutter run -d chrome`)
- iOS build requires **full Xcode** installation (currently incomplete on this machine)

### Things to Optimize
1. **Linting cleanup**: 94 info-level issues to resolve (mostly style)
2. **Floor plan accuracy**: Painters have basic layouts; could be refined with more accurate hospital geometry
3. **Navigation path waypoints**: Currently simple L-shaped or Z-shaped corridors; could add more realistic paths
4. **Appointment time slots**: Schedule data is hardcoded; could add dynamic availability
5. **Search**: Basic string matching; could add fuzzy search or categorized results
6. **Animations**: Path animation works but stagger animations on cards/lists could be added
7. **Accessibility**: Gold paths and banner exist but font scaling and screen reader support need work
8. **iOS testing**: Need full Xcode to build and test on iPhone
9. **Error handling**: Minimal error states in UI; could add proper error/loading states
10. **Performance**: No lazy loading of floor plan painters; could optimize for large hospitals
11. **Islamic geometric patterns**: Mentioned in design spec but not yet implemented on cards
12. **Compass rose entrance markers**: Mentioned in design spec but not yet implemented

### Previously Fixed Bugs
- intl version conflict (^0.19.0 → ^0.20.2)
- TextDirection conflict between dart:ui and intl (fixed with `import 'dart:ui' as ui`)
- NavigationMapWidget parameter mismatches
- Missing AppLocalizations getters (~15 added)
- schedule_repository.dart recursive call
- int? to int type mismatch in navigation_map_widget

## Commands

```bash
# Run on Chrome
flutter run -d chrome

# Run on iOS (requires Xcode)
flutter run -d ios

# Analyze
flutter analyze

# Build web
flutter build web

# Build iOS
flutter build ipa
```

## User Preferences
- Target platform: **iPhone (iOS)** — not Android
- User is in Saudi Arabia
- Future sessions: optimize the app together
