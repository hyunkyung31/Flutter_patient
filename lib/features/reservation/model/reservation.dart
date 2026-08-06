/// 예약 상태 (Django Appointment.Status 와 동일)
enum ReservationStatus {
  requested, // 신청
  confirmed, // 확정
  cancelled, // 취소
  completed, // 완료
}

extension ReservationStatusX on ReservationStatus {
  String get label {
    switch (this) {
      case ReservationStatus.requested:
        return '신청됨';
      case ReservationStatus.confirmed:
        return '확정';
      case ReservationStatus.cancelled:
        return '취소';
      case ReservationStatus.completed:
        return '완료';
    }
  }

  static ReservationStatus fromName(String? raw) {
    return ReservationStatus.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => ReservationStatus.requested,
    );
  }
}

/// Django `/api/appointments/` 응답과 맞춘 예약 모델
class Reservation {
  final String id;
  final String? patientId;
  final String doctorId;
  final String department;
  final String doctorName;
  final DateTime dateTime;
  final String? memo;
  final ReservationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Reservation({
    required this.id,
    this.patientId,
    required this.doctorId,
    required this.department,
    required this.doctorName,
    required this.dateTime,
    this.memo,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  Reservation copyWith({
    String? doctorId,
    String? department,
    String? doctorName,
    DateTime? dateTime,
    String? memo,
    ReservationStatus? status,
    DateTime? updatedAt,
  }) {
    return Reservation(
      id: id,
      patientId: patientId,
      doctorId: doctorId ?? this.doctorId,
      department: department ?? this.department,
      doctorName: doctorName ?? this.doctorName,
      dateTime: dateTime ?? this.dateTime,
      memo: memo ?? this.memo,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'patient_id': patientId,
        'doctor_id': doctorId,
        'department': department,
        'doctor_name': doctorName,
        'scheduled_at': dateTime.toIso8601String(),
        'memo': memo,
        'status': status.name,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory Reservation.fromJson(Map<String, dynamic> json) {
    final scheduled = json['scheduled_at'] ?? json['scheduledAt'] ?? json['dateTime'];
    final created = json['created_at'] ?? json['createdAt'];
    final updated = json['updated_at'] ?? json['updatedAt'];
    final memoRaw = json['memo']?.toString();

    return Reservation(
      id: json['id']?.toString() ?? '',
      patientId: json['patient_id']?.toString() ?? json['patientId']?.toString(),
      doctorId: json['doctor_id']?.toString() ??
          json['doctorId']?.toString() ??
          '',
      department: json['department']?.toString() ?? '',
      doctorName: json['doctor_name']?.toString() ??
          json['doctorName']?.toString() ??
          '',
      dateTime: (DateTime.tryParse(scheduled?.toString() ?? '') ?? DateTime.now())
          .toLocal(),
      memo: (memoRaw == null || memoRaw.isEmpty) ? null : memoRaw,
      status: ReservationStatusX.fromName(json['status']?.toString()),
      createdAt:
          (DateTime.tryParse(created?.toString() ?? '') ?? DateTime.now())
              .toLocal(),
      updatedAt:
          (DateTime.tryParse(updated?.toString() ?? '') ?? DateTime.now())
              .toLocal(),
    );
  }
}
