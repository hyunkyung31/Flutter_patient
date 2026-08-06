import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:patient_app/core/network/api_client.dart';
import 'package:patient_app/core/network/api_endpoints.dart';
import 'package:patient_app/core/theme/app_colors.dart';

import '../model/reservation.dart';
import '../repository/reservation_remote_repository.dart';

/// 예약 신청 / 변경 폼 (서버 Appointment API 연동)
class ReservationFormPage extends StatefulWidget {
  const ReservationFormPage({super.key, this.existing});

  final Reservation? existing;

  @override
  State<ReservationFormPage> createState() => _ReservationFormPageState();
}

class _ReservationFormPageState extends State<ReservationFormPage> {
  final _repo = ReservationRemoteRepository();
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
  String? _doctorId;
  String? _doctorName;
  DateTime? _date;
  TimeOfDay? _time;
  bool _saving = false;
  bool _loadingDoctors = false;

  /// 진료 예약 가능 시간 (30분 단위)
  static const _slotStartHour = 9;
  static const _slotEndHour = 17;
  static const _slotEndMinute = 30;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final ex = widget.existing;
    if (ex != null) {
      _department = ex.department;
      _doctorId = ex.doctorId;
      _doctorName = ex.doctorName;
      _date = DateTime(ex.dateTime.year, ex.dateTime.month, ex.dateTime.day);
      _time = _snapToHalfHour(
        TimeOfDay(hour: ex.dateTime.hour, minute: ex.dateTime.minute),
      );
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
          final id = item['doctor_id']?.toString() ?? '';
          final name = item['doctor_name']?.toString() ?? '';
          final dept = item['department']?.toString() ?? '';
          if (id.isEmpty || name.isEmpty) continue;
          list.add(_DoctorOption(id: id, name: name, department: dept));
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
          if (_isEdit) {
            // 변경 시 담당의는 서버에서 변경 불가 → 기존 값 유지
            return;
          }
          final filtered = _filteredDoctors;
          if (filtered.isNotEmpty) {
            final match = filtered.where((d) => d.id == _doctorId);
            final selected = match.isNotEmpty ? match.first : filtered.first;
            _doctorId = selected.id;
            _doctorName = selected.name;
          }
        });
      }
    } on DioException {
      // 의사 목록 실패 시에도 신청은 primary_doctor_id 로 가능
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

  TimeOfDay _snapToHalfHour(TimeOfDay time) {
    final totalMinutes = time.hour * 60 + time.minute;
    final snapped = ((totalMinutes + 15) ~/ 30) * 30;
    final minMinutes = _slotStartHour * 60;
    final maxMinutes = _slotEndHour * 60 + _slotEndMinute;
    final clamped = snapped < minMinutes
        ? minMinutes
        : snapped > maxMinutes
            ? maxMinutes
            : snapped;
    return TimeOfDay(hour: clamped ~/ 60, minute: clamped % 60);
  }

  List<TimeOfDay> _halfHourSlots() {
    final slots = <TimeOfDay>[];
    var minutes = _slotStartHour * 60;
    final end = _slotEndHour * 60 + _slotEndMinute;
    while (minutes <= end) {
      slots.add(TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60));
      minutes += 30;
    }
    return slots;
  }

  bool _isSlotAvailable(TimeOfDay slot) {
    final date = _date;
    if (date == null) return true;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(date.year, date.month, date.day);
    if (selectedDay.isAfter(today)) return true;
    if (selectedDay.isBefore(today)) return false;
    final slotDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      slot.hour,
      slot.minute,
    );
    return !slotDateTime.isBefore(now);
  }

  String _formatSlot(TimeOfDay slot) {
    final hour = slot.hour.toString().padLeft(2, '0');
    final minute = slot.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      // 홈 '오늘의 환자 현황'과 맞추기 위해 기본 선택일을 오늘로 둔다.
      initialDate: _date ?? DateTime(now.year, now.month, now.day),
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 180)),
      helpText: '예약 날짜',
    );
    if (picked == null) return;
    setState(() {
      _date = picked;
      // 날짜 변경 후 지난 시간대면 선택 해제
      if (_time != null && !_isSlotAvailable(_time!)) {
        _time = null;
      }
    });
  }

  Future<void> _pickTime() async {
    if (_date == null) {
      _toast('날짜를 먼저 선택해주세요.');
      return;
    }

    final slots = _halfHourSlots();
    final available = slots.where(_isSlotAvailable).toList(growable: false);
    if (available.isEmpty) {
      _toast('선택한 날짜에 예약 가능한 시간이 없습니다.');
      return;
    }

    final selected = await showModalBottomSheet<TimeOfDay>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.lightBlue,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '예약 시간',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '30분 단위로 선택하세요 (09:00 ~ 17:30)',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.5,
                  ),
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final slot in slots)
                          _TimeSlotChip(
                            label: _formatSlot(slot),
                            selected: _time?.hour == slot.hour &&
                                _time?.minute == slot.minute,
                            enabled: _isSlotAvailable(slot),
                            onTap: () => Navigator.pop(sheetContext, slot),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected == null) return;
    setState(() => _time = selected);
  }

  Future<void> _submit() async {
    final dept = _department?.trim() ?? '';
    if (dept.isEmpty) {
      _toast('진료과를 선택해주세요.');
      return;
    }
    if (!_isEdit && (_doctorId == null || _doctorId!.trim().isEmpty) && _doctors.isNotEmpty) {
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
        await _repo.update(
          id: widget.existing!.id,
          dateTime: dt,
          memo: _memoController.text.trim(),
          department: dept,
        );
      } else {
        await _repo.create(
          department: dept,
          doctorId: _doctorId,
          dateTime: dt,
          memo: _memoController.text.trim(),
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      _toast(e.toString().replaceFirst('Exception: ', ''));
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
    final timeLabel = _time == null ? '시간 선택' : _formatSlot(_time!);
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
            onChanged: _isEdit
                ? null
                : (v) {
                    setState(() {
                      _department = v;
                      final filtered = _filteredDoctors;
                      if (filtered.isNotEmpty) {
                        _doctorId = filtered.first.id;
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
          else if (_isEdit)
            TextFormField(
              initialValue: _doctorName?.isNotEmpty == true
                  ? _doctorName
                  : (_doctorId ?? '담당의'),
              enabled: false,
              decoration: _inputDecoration(hint: '담당 의사'),
            )
          else if (doctors.isEmpty)
            InputDecorator(
              decoration: _inputDecoration(),
              child: const Text(
                '의사 목록을 불러오지 못했습니다. 담당의로 자동 배정됩니다.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            )
          else
            DropdownButtonFormField<String>(
              value: doctors.any((d) => d.id == _doctorId)
                  ? _doctorId
                  : doctors.first.id,
              items: doctors
                  .map(
                    (d) => DropdownMenuItem(
                      value: d.id,
                      child: Text('${d.name} (${d.department})'),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                final selected = doctors.firstWhere((d) => d.id == v);
                setState(() {
                  _doctorId = selected.id;
                  _doctorName = selected.name;
                });
              },
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
  const _DoctorOption({
    required this.id,
    required this.name,
    required this.department,
  });
  final String id;
  final String name;
  final String department;
}

class _TimeSlotChip extends StatelessWidget {
  const _TimeSlotChip({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = !enabled
        ? AppColors.background
        : selected
            ? AppColors.primary
            : AppColors.lightBlue;
    final foreground = !enabled
        ? AppColors.textSecondary.withValues(alpha: 0.45)
        : selected
            ? AppColors.white
            : AppColors.primary;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 76,
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
