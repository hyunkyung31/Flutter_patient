import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../model/reservation.dart';

/// Django Appointment API 연동
/// - GET  /api/appointments/me/
/// - POST /api/appointments/
/// - PATCH /api/appointments/{id}/
class ReservationRemoteRepository {
  Future<List<Reservation>> fetchAll({String? status}) async {
    try {
      final query = <String, dynamic>{};
      if (status != null && status.isNotEmpty) {
        query['status'] = status;
      }
      final res = await ApiClient.dio.get(
        ApiEndpoints.appointmentsMe,
        queryParameters: query.isEmpty ? null : query,
      );
      return _parseList(res.data);
    } on DioException catch (e) {
      throw Exception(_dioMessage(e, fallback: '예약 목록 조회 실패'));
    }
  }

  Future<Reservation> create({
    required String department,
    required DateTime dateTime,
    String? doctorId,
    String? memo,
  }) async {
    try {
      final trimmedDoctorId = doctorId?.trim();
      final body = <String, dynamic>{
        'department': department,
        'scheduled_at': dateTime.toUtc().toIso8601String(),
        if (trimmedDoctorId != null && trimmedDoctorId.isNotEmpty)
          'doctor_id': trimmedDoctorId,
        'memo': ?memo,
      };
      final res = await ApiClient.dio.post(
        ApiEndpoints.appointments,
        data: body,
      );
      final data = res.data;
      if (data is! Map) {
        throw Exception('서버 응답 형식이 올바르지 않습니다.');
      }
      return Reservation.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      throw Exception(_dioMessage(e, fallback: '예약 신청 실패'));
    }
  }

  Future<Reservation> update({
    required String id,
    DateTime? dateTime,
    String? memo,
    String? department,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (dateTime != null) {
        body['scheduled_at'] = dateTime.toUtc().toIso8601String();
      }
      if (memo != null) body['memo'] = memo;
      if (department != null) body['department'] = department;
      if (body.isEmpty) {
        throw Exception('변경할 내용이 없습니다.');
      }

      final res = await ApiClient.dio.patch(
        ApiEndpoints.appointmentDetail(id),
        data: body,
      );
      final data = res.data;
      if (data is! Map) {
        throw Exception('서버 응답 형식이 올바르지 않습니다.');
      }
      return Reservation.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      throw Exception(_dioMessage(e, fallback: '예약 변경 실패'));
    }
  }

  Future<Reservation> cancel(String id) async {
    try {
      final res = await ApiClient.dio.patch(
        ApiEndpoints.appointmentDetail(id),
        data: {'status': 'cancelled'},
      );
      final data = res.data;
      if (data is! Map) {
        throw Exception('서버 응답 형식이 올바르지 않습니다.');
      }
      return Reservation.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      throw Exception(_dioMessage(e, fallback: '예약 취소 실패'));
    }
  }

  Future<Reservation?> findById(String id) async {
    try {
      final res = await ApiClient.dio.get(
        ApiEndpoints.appointmentDetail(id),
      );
      final data = res.data;
      if (data is! Map) return null;
      return Reservation.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw Exception(_dioMessage(e, fallback: '예약 조회 실패'));
    }
  }

  List<Reservation> _parseList(dynamic data) {
    List<dynamic>? raw;
    if (data is Map && data['results'] is List) {
      raw = data['results'] as List;
    } else if (data is List) {
      raw = data;
    }
    if (raw == null) return [];

    final list = raw
        .whereType<Map>()
        .map((e) => Reservation.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    list.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return list;
  }

  String _dioMessage(DioException e, {required String fallback}) {
    final status = e.response?.statusCode;
    final detail = e.response?.data;
    final msg = (detail is Map && detail['detail'] != null)
        ? detail['detail'].toString()
        : (e.message ?? e.type.toString());
    return '$fallback${status != null ? ' ($status)' : ''}: $msg';
  }
}
