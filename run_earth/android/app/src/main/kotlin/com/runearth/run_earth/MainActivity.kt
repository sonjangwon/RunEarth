package com.runearth.run_earth

import android.content.Intent
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * 절전 모드 안내용 채널 하나만 연다.
 *
 * 정본: `docs/features/run-flow.md` 7 '기기 절전 모드가 켜진 채 START'.
 *
 * `battery_plus` 패키지를 쓰지 않는 이유: 호출이 한 줄이고, 버전 판정까지
 * 여기서 함께 끝난다. 의존성을 늘릴 값이 아니다(2026-09-27 결정).
 */
class MainActivity : FlutterActivity() {

    private val channelName = "com.runearth.run_earth/power"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isPowerSaveBlocking" -> result.success(isPowerSaveBlocking())
                    "openBatterySaverSettings" -> {
                        openBatterySaverSettings()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /**
     * **위치가 실제로 끊기는 조건일 때만** true.
     *
     * Android 9(API 28) 이하는 `절전 모드 + 화면 꺼짐` 이면 OS 가 위치 서비스를
     * 정지시키고 앱이 막을 수 없다(2026-09-26 노트8 실측: 205초 공백, 재획득
     * 좌표의 정확도 533m). **Android 10 부터는 이 동작이 없어** 버전을 함께
     * 본다 — 안 그러면 최신 기기 사용자가 아무 문제 없는데도 경고를 본다.
     *
     * 제조사 자체 절전(삼성 '최대 절전' 등)은 여기서 안 잡힌다.
     * `isPowerSaveMode()` 는 안드로이드 표준 절전만 읽는다(run-flow.md 6 [미검증]).
     */
    private fun isPowerSaveBlocking(): Boolean {
        if (Build.VERSION.SDK_INT > Build.VERSION_CODES.P) return false
        val pm = getSystemService(POWER_SERVICE) as? PowerManager ?: return false
        return pm.isPowerSaveMode
    }

    /**
     * 절전 모드 설정 화면으로 보낸다.
     *
     * 앱 설정(`openAppSettings`)이 아니라 **시스템 배터리 설정**이라야 한다 —
     * 끄는 스위치가 거기 있다. 기기에 이 화면이 없으면 배터리 설정으로
     * 떨어뜨리고, 그것도 없으면 아무것도 하지 않는다(러닝을 막지 않는다).
     */
    private fun openBatterySaverSettings() {
        val candidates = listOf(
            Intent(Settings.ACTION_BATTERY_SAVER_SETTINGS),
            Intent(Settings.ACTION_SETTINGS),
        )
        for (intent in candidates) {
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            if (intent.resolveActivity(packageManager) != null) {
                startActivity(intent)
                return
            }
        }
    }
}
