/// SecureStorage / SharedPreferences 키 모음
class StorageKeys {
  StorageKeys._();

  static const accessToken = 'access_token';
  static const refreshToken = 'refresh_token';
  static const patientId = 'patient_id';
  static const patientName = 'patient_name';

  /// 자동로그인 on/off (기본: 로그인 성공 시 true)
  static const autoLoginEnabled = 'auto_login_enabled';

  /// 생체인증(지문/Face) on/off
  static const biometricEnabled = 'biometric_enabled';

  /// 로컬 예약 목록 (SharedPreferences JSON)
  static const reservations = 'local_reservations';
}
