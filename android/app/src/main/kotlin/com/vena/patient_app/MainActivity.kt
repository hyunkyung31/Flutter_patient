package com.vena.patient_app

import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.util.Base64
import android.util.Log
import io.flutter.embedding.android.FlutterFragmentActivity
import java.security.MessageDigest

/// local_auth(생체인증)은 FlutterFragmentActivity 필요
class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // 카카오 콘솔 등록용 Key Hash (Kakao SDK 의존 없이 PackageManager로 계산)
        logKakaoKeyHash()
    }

    private fun logKakaoKeyHash() {
        try {
            val signatures = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                val info = packageManager.getPackageInfo(
                    packageName,
                    PackageManager.GET_SIGNING_CERTIFICATES,
                )
                info.signingInfo?.apkContentsSigners
            } else {
                @Suppress("DEPRECATION")
                val info = packageManager.getPackageInfo(
                    packageName,
                    PackageManager.GET_SIGNATURES,
                )
                @Suppress("DEPRECATION")
                info.signatures
            }

            signatures?.forEach { signature ->
                val md = MessageDigest.getInstance("SHA")
                md.update(signature.toByteArray())
                val keyHash = Base64.encodeToString(md.digest(), Base64.NO_WRAP)
                Log.i(
                    "KakaoKeyHash",
                    "Register this Android key hash in Kakao Developers: $keyHash",
                )
            }
        } catch (e: Exception) {
            Log.w("KakaoKeyHash", "Failed to compute key hash", e)
        }
    }
}
