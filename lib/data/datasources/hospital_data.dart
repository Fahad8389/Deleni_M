import '../models/hospital.dart';

final List<Hospital> hospitals = [
  Hospital(
    id: 'king-faisal',
    name: const LocaleString(
      en: 'King Faisal Specialist Hospital',
      ar: 'مستشفى الملك فيصل التخصصي',
    ),
    address: const LocaleString(
      en: 'Riyadh, Saudi Arabia',
      ar: 'الرياض، المملكة العربية السعودية',
    ),
    floors: [
      Floor(
        id: 0,
        name: const LocaleString(en: 'Ground Floor', ar: 'الطابق الأرضي'),
        entrance: const Position(x: 15, y: 50),
        destinations: const [
          Destination(
            id: 'emergency-gf',
            name: LocaleString(en: 'Emergency Department', ar: 'قسم الطوارئ'),
            type: DestinationType.emergency,
            floor: 0,
            position: Position(x: 82, y: 41),
          ),
          Destination(
            id: 'reception-gf',
            name: LocaleString(en: 'Main Reception', ar: 'الاستقبال الرئيسي'),
            type: DestinationType.department,
            floor: 0,
            position: Position(x: 25, y: 50),
          ),
          Destination(
            id: 'pharmacy-gf',
            name: LocaleString(en: 'Main Pharmacy', ar: 'الصيدلية الرئيسية'),
            type: DestinationType.department,
            floor: 0,
            position: Position(x: 77, y: 55),
          ),
          Destination(
            id: 'radiology-gf',
            name: LocaleString(en: 'Radiology Department', ar: 'قسم الأشعة'),
            type: DestinationType.department,
            floor: 0,
            position: Position(x: 47, y: 55),
          ),
        ],
      ),
      Floor(
        id: 1,
        name: const LocaleString(en: 'First Floor', ar: 'الطابق الأول'),
        entrance: const Position(x: 15, y: 50),
        destinations: const [
          Destination(
            id: 'cardiology-1f',
            name: LocaleString(en: 'Cardiology Clinic', ar: 'عيادة القلب'),
            type: DestinationType.clinic,
            floor: 1,
            position: Position(x: 40, y: 30),
            roomNumber: '105',
          ),
          Destination(
            id: 'neurology-1f',
            name: LocaleString(en: 'Neurology Clinic', ar: 'عيادة الأعصاب'),
            type: DestinationType.clinic,
            floor: 1,
            position: Position(x: 60, y: 30),
            roomNumber: '108',
          ),
          Destination(
            id: 'orthopedics-1f',
            name: LocaleString(en: 'Orthopedics Clinic', ar: 'عيادة العظام'),
            type: DestinationType.clinic,
            floor: 1,
            position: Position(x: 75, y: 50),
            roomNumber: '110',
          ),
          Destination(
            id: 'room-101',
            name: LocaleString(en: 'Room 101', ar: 'غرفة ١٠١'),
            type: DestinationType.room,
            floor: 1,
            position: Position(x: 35, y: 70),
            roomNumber: '101',
          ),
          Destination(
            id: 'room-102',
            name: LocaleString(en: 'Room 102', ar: 'غرفة ١٠٢'),
            type: DestinationType.room,
            floor: 1,
            position: Position(x: 50, y: 70),
            roomNumber: '102',
          ),
        ],
      ),
      Floor(
        id: 2,
        name: const LocaleString(en: 'Second Floor', ar: 'الطابق الثاني'),
        entrance: const Position(x: 15, y: 50),
        destinations: const [
          Destination(
            id: 'pediatrics-2f',
            name: LocaleString(en: 'Pediatrics Clinic', ar: 'عيادة الأطفال'),
            type: DestinationType.clinic,
            floor: 2,
            position: Position(x: 45, y: 25),
            roomNumber: '203',
          ),
          Destination(
            id: 'dermatology-2f',
            name: LocaleString(en: 'Dermatology Clinic', ar: 'عيادة الجلدية'),
            type: DestinationType.clinic,
            floor: 2,
            position: Position(x: 65, y: 25),
            roomNumber: '205',
          ),
          Destination(
            id: 'icu-2f',
            name: LocaleString(en: 'ICU Department', ar: 'وحدة العناية المركزة'),
            type: DestinationType.department,
            floor: 2,
            position: Position(x: 80, y: 50),
          ),
          Destination(
            id: 'room-201',
            name: LocaleString(en: 'Room 201', ar: 'غرفة ٢٠١'),
            type: DestinationType.room,
            floor: 2,
            position: Position(x: 40, y: 65),
            roomNumber: '201',
          ),
          Destination(
            id: 'room-202',
            name: LocaleString(en: 'Room 202', ar: 'غرفة ٢٠٢'),
            type: DestinationType.room,
            floor: 2,
            position: Position(x: 55, y: 65),
            roomNumber: '202',
          ),
        ],
      ),
    ],
  ),
  Hospital(
    id: 'riyadh-care',
    name: const LocaleString(
      en: 'Riyadh Care Hospital',
      ar: 'مستشفى رعاية الرياض',
    ),
    address: const LocaleString(
      en: 'Riyadh, Saudi Arabia',
      ar: 'الرياض، المملكة العربية السعودية',
    ),
    floors: [
      Floor(
        id: 0,
        name: const LocaleString(en: 'Ground Floor', ar: 'الطابق الأرضي'),
        entrance: const Position(x: 20, y: 50),
        destinations: const [
          Destination(
            id: 'emergency-rc-gf',
            name: LocaleString(en: 'Emergency Department', ar: 'قسم الطوارئ'),
            type: DestinationType.emergency,
            floor: 0,
            position: Position(x: 75, y: 35),
          ),
          Destination(
            id: 'lab-rc-gf',
            name: LocaleString(en: 'Laboratory', ar: 'المختبر'),
            type: DestinationType.department,
            floor: 0,
            position: Position(x: 60, y: 65),
          ),
        ],
      ),
      Floor(
        id: 1,
        name: const LocaleString(en: 'First Floor', ar: 'الطابق الأول'),
        entrance: const Position(x: 20, y: 50),
        destinations: const [
          Destination(
            id: 'ent-rc-1f',
            name: LocaleString(en: 'ENT Clinic', ar: 'عيادة الأنف والأذن والحنجرة'),
            type: DestinationType.clinic,
            floor: 1,
            position: Position(x: 50, y: 30),
            roomNumber: '112',
          ),
          Destination(
            id: 'ophthalmology-rc-1f',
            name: LocaleString(en: 'Ophthalmology Clinic', ar: 'عيادة العيون'),
            type: DestinationType.clinic,
            floor: 1,
            position: Position(x: 70, y: 40),
            roomNumber: '115',
          ),
        ],
      ),
      Floor(
        id: 2,
        name: const LocaleString(en: 'Second Floor', ar: 'الطابق الثاني'),
        entrance: const Position(x: 20, y: 50),
        destinations: const [
          Destination(
            id: 'surgery-rc-2f',
            name: LocaleString(en: 'Surgery Department', ar: 'قسم الجراحة'),
            type: DestinationType.department,
            floor: 2,
            position: Position(x: 60, y: 40),
          ),
        ],
      ),
    ],
  ),
];
