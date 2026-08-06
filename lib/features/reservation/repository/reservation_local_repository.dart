import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/storage_keys.dart';
import '../model/reservation.dart';

/// 레거시 로컬 저장소. 서버 Appointment API 연동 후 사용하지 않음.
/// (오프라인/마이그레이션 참고용으로만 유지)
@Deprecated('Use ReservationRemoteRepository')
class ReservationLocalRepository {
  Future<List<Reservation>> fetchAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(StorageKeys.reservations);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];

    final list = decoded
        .whereType<Map>()
        .map((e) => Reservation.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    list.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return list;
  }

  Future<void> _saveAll(List<Reservation> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(StorageKeys.reservations, encoded);
  }

  Future<Reservation> create({
    required String department,
    required String doctorName,
    required DateTime dateTime,
    String doctorId = '',
    String? memo,
  }) async {
    final now = DateTime.now();
    final item = Reservation(
      id: 'rsv_${now.millisecondsSinceEpoch}',
      doctorId: doctorId,
      department: department,
      doctorName: doctorName,
      dateTime: dateTime,
      memo: memo,
      status: ReservationStatus.requested,
      createdAt: now,
      updatedAt: now,
    );
    final list = await fetchAll();
    list.add(item);
    await _saveAll(list);
    return item;
  }

  Future<Reservation?> update(Reservation updated) async {
    final list = await fetchAll();
    final idx = list.indexWhere((e) => e.id == updated.id);
    if (idx < 0) return null;
    list[idx] = updated.copyWith(updatedAt: DateTime.now());
    await _saveAll(list);
    return list[idx];
  }

  Future<bool> cancel(String id) async {
    final list = await fetchAll();
    final idx = list.indexWhere((e) => e.id == id);
    if (idx < 0) return false;
    list[idx] = list[idx].copyWith(
      status: ReservationStatus.cancelled,
      updatedAt: DateTime.now(),
    );
    await _saveAll(list);
    return true;
  }

  Future<Reservation?> findById(String id) async {
    final list = await fetchAll();
    try {
      return list.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
