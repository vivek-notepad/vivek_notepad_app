package com.viveksingh.notepad_app

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.os.Build
import android.os.Bundle
import android.widget.RemoteViews
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "com.viveksingh.notepad_app/widget"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "requestPinWidget" -> {
                        try {
                            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
                                result.success(false)
                                return@setMethodCallHandler
                            }

                            val appWidgetManager =
                                AppWidgetManager.getInstance(applicationContext)
                            if (!appWidgetManager.isRequestPinAppWidgetSupported) {
                                result.success(false)
                                return@setMethodCallHandler
                            }

                            val provider =
                                ComponentName(applicationContext, NotesWidgetProvider::class.java)
                            val preview = RemoteViews(
                                applicationContext.packageName,
                                R.layout.notes_widget_preview,
                            )
                            val options = Bundle().apply {
                                putParcelable(AppWidgetManager.EXTRA_APPWIDGET_PREVIEW, preview)
                            }

                            appWidgetManager.requestPinAppWidget(provider, options, null)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("WIDGET_PIN_FAILED", e.message, null)
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }
}
