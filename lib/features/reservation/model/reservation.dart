/// 예약 상태
enum ReservationStatus {
  requested, // 신청
  confirmed, // 확정(병원 확인 가정)
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

class Reservation {
  final String id;
  final String department;
  final String doctorName;
  final DateTime dateTime;
  final String? memo;
  final ReservationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Reservation({
    required this.id,
    required this.department,
    required this.doctorName,
    required this.dateTime,
    this.memo,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  Reservation copyWith({
    String? department,
    String? doctorName,
    DateTime? dateTime,
    String? memo,
    ReservationStatus? status,
    DateTime? updatedAt,
  }) {
    return Reservation(
      id: id,
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
        'department': department,
        'doctorName': doctorName,
        'dateTime': dateTime.toIso8601String(),
        'memo': memo,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      doctorName: json['doctorName']?.toString() ?? '',
      dateTime: DateTime.tryParse(json['dateTime']?.toString() ?? '') ??
          DateTime.now(),
      memo: json['memo']?.toString(),
      status: ReservationStatusX.fromName(json['status']?.toString()),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
