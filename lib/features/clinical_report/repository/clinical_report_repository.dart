import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/storage/secure_storage.dart';
import '../model/clinical_report.dart';

/// 환자용 임상 보고서 API
///
/// 우선순위:
/// 1) GET /api/emr-signoffs/me/
/// 2) GET /api/emr-signoffs/ (환자 JWT면 본인 건만 오도록 서버 스코프 기대)
/// 3) GET /api/patients/{id}/ 응답 안의 emr_signoffs / clinical_reports
class ClinicalReportRepository {
  Future<List<ClinicalReport>> fetchMyReports() async {
    final errors = <String>[];

    // 1) me endpoint
    try {
      final res = await ApiClient.dio.get(ApiEndpoints.clinicalReportsMe);
      final list = _filterVisible(_parseList(res.data));
      if (list.isNotEmpty) return list;
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status != 404 && status != 405) {
        errors.add(_dioMessage(error, fallback: 'me 목록 실패'));
      }
    }

    // 2) general list (role-scoped)
    try {
      final res = await ApiClient.dio.get(ApiEndpoints.clinicalReports);
      final list = _filterVisible(_parseList(res.data));
      if (list.isNotEmpty) return list;
    } on DioException catch (error) {
      errors.add(_dioMessage(error, fallback: '보고서 목록 실패'));
    }

    // 3) nested in patient detail
    try {
      final fromPatient = await _fetchFromPatientDetail();
      if (fromPatient.isNotEmpty) return fromPatient;
    } on DioException catch (error) {
      errors.add(_dioMessage(error, fallback: '환자 상세 조회 실패'));
    } catch (error) {
      errors.add(error.toString());
    }

    // 전부 비었으면 빈 목록 (에러가 있어도 UI empty로 두고 로그)
    if (errors.isNotEmpty) {
      debugPrint('ClinicalReportRepository fetch warnings: $errors');
    }
    return const <ClinicalReport>[];
  }

  Future<List<ClinicalReport>> _fetchFromPatientDetail() async {
    final patientId = await SecureStorageService.getPatientId();
    if (patientId == null || patientId.trim().isEmpty) {
      return const <ClinicalReport>[];
    }

    final res = await ApiClient.dio.get(
      ApiEndpoints.patientDetail(patientId.trim()),
    );
    final data = res.data;
    if (data is! Map) return const <ClinicalReport>[];

    final map = Map<String, dynamic>.from(data);
    final nested = map['emr_signoffs'] ??
        map['clinical_reports'] ??
        map['sign_offs'] ??
        map['reports'];
    return _filterVisible(_parseList(nested));
  }

  Future<ClinicalReport> fetchReport(int signOffId) async {
    try {
      final res = await ApiClient.dio.get(
        ApiEndpoints.clinicalReportDetail(signOffId),
      );
      final data = res.data;
      if (data is! Map) {
        throw Exception('임상 보고서 응답 형식이 올바르지 않습니다.');
      }
      return ClinicalReport.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      throw Exception(_dioMessage(e, fallback: '임상 보고서를 불러오지 못했습니다.'));
    }
  }

  Future<Uint8List> downloadPdf(int signOffId) async {
    try {
      final res = await ApiClient.dio.get<List<int>>(
        ApiEndpoints.clinicalReportPdf(signOffId),
        options: Options(
          responseType: ResponseType.bytes,
          // DRF default renderers are JSON-only; Accept: application/pdf → 406
          headers: {'Accept': '*/*'},
        ),
      );
      final bytes = res.data;
      if (bytes == null || bytes.isEmpty) {
        throw Exception('다운로드한 PDF가 비어 있습니다.');
      }
      return Uint8List.fromList(bytes);
    } on DioException catch (e) {
      throw Exception(_dioMessage(e, fallback: '임상 보고서 PDF를 받지 못했습니다.'));
    }
  }

  List<ClinicalReport> _filterVisible(List<ClinicalReport> source) {
    // 전달 완료 우선. 없으면 reportReady라도 같은 환자 건은 노출
    // (서버 /me/ 미구현·transmit 지연 대비)
    final transmitted = source.where((e) => e.emrTransmitted).toList();
    if (transmitted.isNotEmpty) {
      return _sorted(transmitted);
    }
    final ready = source.where((e) => e.reportReady).toList();
    return _sorted(ready);
  }

  List<ClinicalReport> _sorted(List<ClinicalReport> source) {
    final list = List<ClinicalReport>.from(source);
    list.sort((a, b) {
      final aTime = a.transmittedAt ?? a.reportGeneratedAt ?? a.createdAt;
      final bTime = b.transmittedAt ?? b.reportGeneratedAt ?? b.createdAt;
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return bTime.compareTo(aTime);
    });
    return list;
  }

  List<ClinicalReport> _parseList(dynamic data) {
    List<dynamic> raw;
    if (data is Map) {
      final items = data['results'] ?? data['emr_signoffs'] ?? data['data'];
      raw = items is List ? items : const <dynamic>[];
    } else if (data is List) {
      raw = data;
    } else {
      raw = const <dynamic>[];
    }

    return raw
        .whereType<Map>()
        .map((e) => ClinicalReport.fromJson(Map<String, dynamic>.from(e)))
        .where((e) => e.id.isNotEmpty)
        .toList();
  }

  String _dioMessage(DioException error, {required String fallback}) {
    final detail = _extractDetail(error.response?.data);
    if (detail != null) return detail;

    final status = error.response?.statusCode;
    if (status == 404) {
      return '저장된 PDF 파일을 찾을 수 없습니다. 의사 앱에서 보고서를 다시 생성·전달해 주세요.';
    }
    if (status != null) return '$fallback ($status)';
    return fallback;
  }

  String? _extractDetail(Object? data) {
    if (data is Map) {
      final detail = data['detail']?.toString().trim();
      if (detail != null && detail.isNotEmpty) return detail;
      final message = data['message']?.toString().trim();
      if (message != null && message.isNotEmpty) return message;
      return null;
    }
    if (data is List<int>) {
      try {
        final text = utf8.decode(data, allowMalformed: true).trim();
        if (text.startsWith('{')) {
          final decoded = jsonDecode(text);
          if (decoded is Map) {
            return _extractDetail(Map<String, dynamic>.from(decoded));
          }
        }
        if (text.isNotEmpty && text.length < 300) return text;
      } catch (_) {}
    }
    if (data is String) {
      final text = data.trim();
      if (text.isNotEmpty && text.length < 300) return text;
    }
    return null;
  }
}
