import 'package:flutter/material.dart';
import 'package:patient_app/core/theme/app_colors.dart';

import '../model/patient_profile.dart';
import '../repository/patient_profile_repository.dart';

/// 마이페이지 > 내 정보
class MyInfoPage extends StatefulWidget {
  const MyInfoPage({super.key, this.patientId});

  final String? patientId;

  @override
  State<MyInfoPage> createState() => _MyInfoPageState();
}

class _MyInfoPageState extends State<MyInfoPage> {
  final _repo = PatientProfileRepository();
  late Future<PatientProfile> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.fetchMyProfile(patientId: widget.patientId);
  }

  Future<void> _reload() async {
    setState(() {
      _future = _repo.fetchMyProfile(patientId: widget.patientId);
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('내 정보'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.text,
        elevation: 0,
      ),
      body: FutureBuilder<PatientProfile>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ErrorView(
              message: snapshot.error.toString().replaceFirst('Exception: ', ''),
              onRetry: _reload,
            );
          }

          final profile = snapshot.data;
          if (profile == null) {
            return _ErrorView(
              message: '환자 정보를 불러오지 못했습니다.',
              onRetry: _reload,
            );
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                _ProfileHeader(profile: profile),
                const SizedBox(height: 16),
                _InfoCard(
                  title: '기본 정보',
                  rows: [
                    _InfoRow(label: '이름', value: profile.patientName.isEmpty
                        ? '-'
                        : profile.patientName),
                    _InfoRow(label: '환자 ID', value: profile.patientId.isEmpty
                        ? '-'
                        : profile.patientId),
                    _InfoRow(label: '성별', value: profile.genderLabel),
                    _InfoRow(
                      label: '나이',
                      value: profile.age == null ? '-' : '${profile.age}세',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  title: '담당 의료진',
                  rows: [
                    _InfoRow(
                      label: '담당의',
                      value: profile.primaryDoctorName?.isNotEmpty == true
                          ? profile.primaryDoctorName!
                          : (profile.primaryDoctorId?.isNotEmpty == true
                              ? profile.primaryDoctorId!
                              : '미지정'),
                    ),
                    if (profile.primaryDoctorId != null &&
                        profile.primaryDoctorId!.isNotEmpty &&
                        profile.primaryDoctorName != null)
                      _InfoRow(
                        label: '의사 ID',
                        value: profile.primaryDoctorId!,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  title: '건강 요약',
                  rows: [
                    _InfoRow(
                      label: '주호소',
                      value: _orDash(profile.chiefComplaint),
                    ),
                    _InfoRow(
                      label: 'ECG 결과',
                      value: _orDash(profile.ecgResult),
                    ),
                    _InfoRow(
                      label: 'Troponin T',
                      value: profile.troponinTLevel == null
                          ? '-'
                          : profile.troponinTLevel!.toStringAsFixed(3),
                    ),
                    _InfoRow(
                      label: '병력 점수',
                      value: profile.historyScore?.toString() ?? '-',
                    ),
                    _InfoRow(
                      label: '위험요인 수',
                      value: profile.riskFactorsCount?.toString() ?? '-',
                    ),
                    _InfoRow(
                      label: '검사 건수',
                      value: '${profile.examCount}건',
                    ),
                  ],
                ),
                if (profile.ecgImageUrl != null &&
                    profile.ecgImageUrl!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _EcgPreview(url: profile.ecgImageUrl!),
                ],
                const SizedBox(height: 16),
                Text(
                  '아래로 당겨서 새로고침할 수 있습니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _orDash(String? value) {
    if (value == null || value.trim().isEmpty) return '-';
    return value.trim();
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final PatientProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightBlue),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/mascot/bomi_default.png',
            width: 72,
            height: 72,
            errorBuilder: (_, __, ___) => const CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.lightBlue,
              child: Icon(Icons.person, color: AppColors.primary, size: 36),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.patientName.isEmpty ? '환자' : profile.patientName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  [
                    if (profile.age != null) '${profile.age}세',
                    profile.genderLabel,
                  ].where((e) => e != '-').join(' · '),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID ${profile.patientId}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.rows});

  final String title;
  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBlue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          ...rows,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EcgPreview extends StatelessWidget {
  const _EcgPreview({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBlue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ECG 이미지',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                height: 120,
                alignment: Alignment.center,
                color: AppColors.lightBlue,
                child: const Text(
                  '이미지를 불러올 수 없습니다.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline, size: 40, color: AppColors.accent),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.45,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => onRetry(),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}
