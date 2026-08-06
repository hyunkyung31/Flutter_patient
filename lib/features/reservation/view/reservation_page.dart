import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:patient_app/core/theme/app_colors.dart';

import '../model/reservation.dart';
import '../repository/reservation_remote_repository.dart';
import 'reservation_form_page.dart';

/// 예약 탭: 서버 목록 조회 + 신청/변경/취소
class ReservationPage extends StatefulWidget {
  const ReservationPage({super.key});

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  final _repo = ReservationRemoteRepository();
  late Future<List<Reservation>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.fetchAll();
  }

  Future<void> _reload() async {
    setState(() {
      _future = _repo.fetchAll();
    });
    await _future;
  }

  Future<void> _openCreate() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const ReservationFormPage()),
    );
    if (created == true) await _reload();
  }

  Future<void> _openEdit(Reservation item) async {
    if (item.status == ReservationStatus.cancelled ||
        item.status == ReservationStatus.completed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('취소/완료된 예약은 변경할 수 없습니다.')),
      );
      return;
    }
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ReservationFormPage(existing: item),
      ),
    );
    if (changed == true) await _reload();
  }

  Future<void> _cancel(Reservation item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('예약 취소'),
        content: Text(
          '${DateFormat('yyyy.MM.dd HH:mm').format(item.dateTime)}\n'
          '${item.department} / ${item.doctorName}\n예약을 취소할까요?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('닫기'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.accent),
            child: const Text('취소하기'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _repo.cancel(item.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('예약이 취소되었습니다.')),
      );
      await _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    '예약',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: _openCreate,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('예약 신청'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              '신청 · 조회 · 변경 · 취소 (의사 앱과 서버 예약 연동)',
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: FutureBuilder<List<Reservation>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return _ErrorView(
                    message: snap.error
                        .toString()
                        .replaceFirst('Exception: ', ''),
                    onRetry: _reload,
                  );
                }
                final items = snap.data ?? const <Reservation>[];
                if (items.isEmpty) {
                  return _Empty(onCreate: _openCreate);
                }
                return RefreshIndicator(
                  onRefresh: _reload,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final item = items[i];
                      return _ReservationCard(
                        item: item,
                        onEdit: () => _openEdit(item),
                        onCancel: () => _cancel(item),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 56,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.45,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/mascot/bomi_point.png',
              width: 110,
              height: 110,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.calendar_month_rounded,
                size: 72,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              '아직 예약이 없습니다.\n아래 버튼으로 진료를 신청해보세요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onCreate,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('예약 신청하기'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({
    required this.item,
    required this.onEdit,
    required this.onCancel,
  });

  final Reservation item;
  final VoidCallback onEdit;
  final VoidCallback onCancel;

  Color get _badgeColor {
    switch (item.status) {
      case ReservationStatus.requested:
        return AppColors.secondary;
      case ReservationStatus.confirmed:
        return const Color(0xFF059669);
      case ReservationStatus.cancelled:
        return const Color(0xFF9CA3AF);
      case ReservationStatus.completed:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText =
        DateFormat('yyyy.MM.dd HH:mm').format(item.dateTime);
    final canEdit = item.status == ReservationStatus.requested ||
        item.status == ReservationStatus.confirmed;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBlue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.department,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item.status.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '담당: ${item.doctorName.isEmpty ? item.doctorId : item.doctorName}',
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dateText,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          if (item.memo != null && item.memo!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              item.memo!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (canEdit) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton(
                  onPressed: onEdit,
                  child: const Text('일정 변경'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: onCancel,
                  child: const Text(
                    '취소',
                    style: TextStyle(color: Color(0xFFB91C1C)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
