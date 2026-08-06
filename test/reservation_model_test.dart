import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/features/reservation/model/reservation.dart';

void main() {
  group('Reservation.fromJson', () {
    test('parses Django AppointmentSerializer payload', () {
      final item = Reservation.fromJson({
        'id': 12,
        'patient_id': 'P-2026-HKG',
        'patient_name': '황현경',
        'doctor_id': 'DOC-001',
        'doctor_name': '김순환',
        'department': '순환기내과',
        'scheduled_at': '2026-08-10T01:00:00Z',
        'status': 'requested',
        'memo': '흉통',
        'created_at': '2026-08-05T10:00:00Z',
        'updated_at': '2026-08-05T10:00:00Z',
      });

      expect(item.id, '12');
      expect(item.patientId, 'P-2026-HKG');
      expect(item.doctorId, 'DOC-001');
      expect(item.doctorName, '김순환');
      expect(item.department, '순환기내과');
      expect(item.status, ReservationStatus.requested);
      expect(item.memo, '흉통');
      expect(item.dateTime.isUtc, isFalse);
    });

    test('accepts camelCase local-legacy keys', () {
      final item = Reservation.fromJson({
        'id': 'rsv_1',
        'doctorId': 'DOC-002',
        'doctorName': '이심장',
        'department': '심장혈관외과',
        'dateTime': '2026-09-01T10:30:00.000',
        'status': 'confirmed',
        'createdAt': '2026-08-01T00:00:00.000',
        'updatedAt': '2026-08-01T00:00:00.000',
      });

      expect(item.doctorId, 'DOC-002');
      expect(item.doctorName, '이심장');
      expect(item.status, ReservationStatus.confirmed);
      expect(item.status.label, '확정');
    });
  });
}
