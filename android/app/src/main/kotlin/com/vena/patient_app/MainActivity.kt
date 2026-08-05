package com.vena.patient_app

import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterFragmentActivity

/// local_auth(생체인증)은 FlutterFragmentActivity 필요
class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // 카카오 콘솔에 등록할 Android Key Hash 출력 (다른 PC/폰에서 misconfigured 날 때 사용)
        try {
            val keyHash = com.kakao.sdk.common.util.Utility.getKeyHash(this)
            Log.i("KakaoKeyHash", "Register this Android key hash in Kakao Developers: $keyHash")
        } catch (e: Exception) {
            Log.w("KakaoKeyHash", "Failed to compute key hash", e)
        }
    }
}
