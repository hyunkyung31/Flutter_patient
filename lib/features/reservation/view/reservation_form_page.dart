import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:patient_app/core/network/api_client.dart';
import 'package:patient_app/core/network/api_endpoints.dart';
import 'package:patient_app/core/theme/app_colors.dart';

import '../model/reservation.dart';
import '../repository/reservation_local_repository.dart';

/// 예약 신청 / 변경 폼
class ReservationFormPage extends StatefulWidget {
  const ReservationFormPage({super.key, this.existing});

  final Reservation? existing;

  @override
  State<ReservationFormPage> createState() => _ReservationFormPageState();
}

class _ReservationFormPageState extends State<ReservationFormPage> {
  final _repo = ReservationLocalRepository();
  final _memoController = TextEditingController();

  static const _fallbackDepartments = [
    '순환기내과',
    '심장혈관외과',
    '영상의학과',
    '응급의학과',
  ];

  List<String> _departments = List.of(_fallbackDepartments);
  List<_DoctorOption> _doctors = const [];

  String? _department;
  String? _doctorName;
  DateTime? _date;
  TimeOfDay? _time;
  bool _saving = false;
  bool _loadingDoctors = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final ex = widget.existing;
    if (ex != null) {
      _department = ex.department;
      _doctorName = ex.doctorName;
      _date = DateTime(ex.dateTime.year, ex.dateTime.month, ex.dateTime.day);
      _time = TimeOfDay(hour: ex.dateTime.hour, minute: ex.dateTime.minute);
      _memoController.text = ex.memo ?? '';
    } else {
      _department = _departments.first;
    }
    _loadDoctors();
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _loadDoctors() async {
    setState(() => _loadingDoctors = true);
    try {
      final res = await ApiClient.dio.get(ApiEndpoints.doctors);
      final data = res.data;
      final list = <_DoctorOption>[];
      if (data is List) {
        for (final item in data) {
          if (item is! Map) continue;
          final name = item['doctor_name']?.toString() ?? '';
          final dept = item['department']?.toString() ?? '';
          if (name.isEmpty) continue;
          list.add(_DoctorOption(name: name, department: dept));
        }
      }
      if (!mounted) return;
      if (list.isNotEmpty) {
        final depts = list
            .map((e) => e.department)
            .where((e) => e.trim().isNotEmpty)
            .toSet()
            .toList()
          ..sort();
        setState(() {
          _doctors = list;
          if (depts.isNotEmpty) {
            _departments = depts;
            _department ??= depts.first;
          }
          // 현재 과에 맞는 의사 없으면 첫 의사로
          final filtered = _filteredDoctors;
          if (filtered.isNotEmpty &&
              (_doctorName == null ||
                  !filtered.any((d) => d.name == _doctorName))) {
            _doctorName = filtered.first.name;
          }
        });
      } else {
        setState(() {
          _doctorName ??= '담당의';
        });
      }
    } on DioException {
      if (!mounted) return;
      setState(() {
        _doctorName ??= '담당의';
      });
    } finally {
      if (mounted) setState(() => _loadingDoctors = false);
    }
  }

  List<_DoctorOption> get _filteredDoctors {
    final dept = _department;
    if (dept == null || _doctors.isEmpty) return _doctors;
    final filtered =
        _doctors.where((d) => d.department == dept).toList(growable: false);
    return filtered.isEmpty ? _doctors : filtered;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now.add(const Duration(days: 1)),
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 180)),
      helpText: '예약 날짜',
    );
    if (picked == null) return;
    setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 10, minute: 0),
      helpText: '예약 시간',
    );
    if (picked == null) return;
    setState(() => _time = picked);
  }

  Future<void> _submit() async {
    final dept = _department?.trim() ?? '';
    final doctor = _doctorName?.trim() ?? '';
    if (dept.isEmpty) {
      _toast('진료과를 선택해주세요.');
      return;
    }
    if (doctor.isEmpty) {
      _toast('의사를 선택해주세요.');
      return;
    }
    if (_date == null || _time == null) {
      _toast('날짜와 시간을 선택해주세요.');
      return;
    }

    final dt = DateTime(
      _date!.year,
      _date!.month,
      _date!.day,
      _time!.hour,
      _time!.minute,
    );
    if (dt.isBefore(DateTime.now())) {
      _toast('과거 일시로는 예약할 수 없습니다.');
      return;
    }

    setState(() => _saving = true);
    try {
      if (_isEdit) {
        final updated = widget.existing!.copyWith(
          department: dept,
          doctorName: doctor,
          dateTime: dt,
          memo: _memoController.text.trim(),
          status: ReservationStatus.requested,
        );
        await _repo.update(updated);
      } else {
        await _repo.create(
          department: dept,
          doctorName: doctor,
          dateTime: dt,
          memo: _memoController.text.trim(),
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = _date == null
        ? '날짜 선택'
        : DateFormat('yyyy.MM.dd').format(_date!);
    final timeLabel = _time == null ? '시간 선택' : _time!.format(context);
    final doctors = _filteredDoctors;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEdit ? '예약 변경' : '예약 신청'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.text,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            '진료과',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _department,
            items: _departments
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                .toList(),
            onChanged: (v) {
              setState(() {
                _department = v;
                final filtered = _filteredDoctors;
                if (filtered.isNotEmpty) {
                  _doctorName = filtered.first.name;
                }
              });
            },
            decoration: _inputDecoration(),
          ),
          const SizedBox(height: 16),
          const Text(
            '의사',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          if (_loadingDoctors)
            const LinearProgressIndicator(minHeight: 2)
          else if (doctors.isEmpty)
            TextFormField(
              initialValue: _doctorName ?? '담당의',
              onChanged: (v) => _doctorName = v,
              decoration: _inputDecoration(hint: '의사 이름'),
            )
          else
            DropdownButtonFormField<String>(
              value: doctors.any((d) => d.name == _doctorName)
                  ? _doctorName
                  : doctors.first.name,
              items: doctors
                  .map(
                    (d) => DropdownMenuItem(
                      value: d.name,
                      child: Text('${d.name} (${d.department})'),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _doctorName = v),
              decoration: _inputDecoration(),
            ),
          const SizedBox(height: 16),
          const Text(
            '일시',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today_outlined, size: 16),
                  label: Text(dateLabel),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickTime,
                  icon: const Icon(Icons.schedule_rounded, size: 16),
                  label: Text(timeLabel),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '메모 (선택)',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _memoController,
            maxLines: 3,
            decoration: _inputDecoration(hint: '증상이나 요청사항을 적어주세요'),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: _saving ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _isEdit ? '변경 저장' : '예약 신청',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightBlue),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightBlue),
      ),
    );
  }
}

class _DoctorOption {
  const _DoctorOption({required this.name, required this.department});
  final String name;
  final String department;
}
