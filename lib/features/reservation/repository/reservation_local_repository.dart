import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/storage_keys.dart';
import '../model/reservation.dart';

/// 예약 API가 아직 없으므로 로컬 저장으로 먼저 동작.
/// 나중에 Dio 기반 RemoteRepository로 교체하면 됨.
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
    String? memo,
  }) async {
    final now = DateTime.now();
    final item = Reservation(
      id: 'rsv_${now.millisecondsSinceEpoch}',
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
