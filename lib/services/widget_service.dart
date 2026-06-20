import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';

class WidgetService {
  WidgetService._();
  static final WidgetService instance = WidgetService._();

  static const androidWidgetName = 'NotesWidgetProvider';
  static const qualifiedAndroidName =
      'com.viveksingh.notepad_app.NotesWidgetProvider';
  static const _tipDismissedKey = 'widget_tip_dismissed';
  static const _pinChannel = MethodChannel('com.viveksingh.notepad_app/widget');

  Future<void> init() async {
    try {
      await HomeWidget.setAppGroupId('group.notepad.widget');
    } catch (e) {
      debugPrint('Widget init failed: $e');
    }
  }

  Future<void> updateFromNotes(List<QueryDocumentSnapshot> notes) async {
    try {
      final displayNotes = notes.take(5).map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final title = (data['title'] ?? '').toString().trim();
        if (title.isNotEmpty) return title;

        final content = (data['content'] ?? '').toString().trim();
        if (content.isNotEmpty) {
          return content.length > 40
              ? '${content.substring(0, 40)}...'
              : content;
        }

        final tasks = data['tasks'] as List<dynamic>?;
        if (tasks != null && tasks.isNotEmpty) {
          return (tasks.first['text'] ?? 'Batch note').toString();
        }
        return 'Untitled note';
      }).toList();

      final body = displayNotes.isEmpty
          ? 'No notes yet. Tap to open the app.'
          : displayNotes.map((t) => '• $t').join('\n');

      await HomeWidget.saveWidgetData<String>('note_titles', body);
      await HomeWidget.saveWidgetData<int>('note_count', notes.length);
      await refreshWidget();
    } catch (e) {
      debugPrint('Widget update failed: $e');
    }
  }

  Future<void> syncFromFirestore(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('notes')
          .where('isLocked', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();
      await updateFromNotes(snapshot.docs);
    } catch (e) {
      debugPrint('Widget sync failed: $e');
    }
  }

  Future<bool> refreshWidget() async {
    try {
      final updated = await HomeWidget.updateWidget(
        name: androidWidgetName,
        androidName: androidWidgetName,
        qualifiedAndroidName: qualifiedAndroidName,
      );
      return updated ?? false;
    } catch (e) {
      debugPrint('Widget refresh failed: $e');
      return false;
    }
  }

  Future<bool> isPinWidgetSupported() async {
    try {
      return await HomeWidget.isRequestPinWidgetSupported() ?? false;
    } catch (e) {
      debugPrint('Widget pin support check failed: $e');
      return false;
    }
  }

  Future<bool> requestPinWidget() async {
    try {
      await refreshWidget();
      final pinned = await _pinChannel.invokeMethod<bool>('requestPinWidget');
      if (pinned == true) return true;

      await HomeWidget.requestPinWidget(
        name: androidWidgetName,
        androidName: androidWidgetName,
        qualifiedAndroidName: qualifiedAndroidName,
      );
      return true;
    } on PlatformException catch (e) {
      debugPrint('Widget pin failed: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Widget pin failed: $e');
      return false;
    }
  }

  Future<bool> hasInstalledWidget() async {
    try {
      final widgets = await HomeWidget.getInstalledWidgets();
      return widgets.isNotEmpty;
    } catch (e) {
      debugPrint('Widget install check failed: $e');
      return false;
    }
  }

  Future<bool> shouldShowHomeTip() async {
    try {
      final dismissed =
          await HomeWidget.getWidgetData<bool>(_tipDismissedKey) ?? false;
      if (dismissed) return false;
      return !(await hasInstalledWidget());
    } catch (e) {
      debugPrint('Widget tip check failed: $e');
      return false;
    }
  }

  Future<void> dismissHomeTip() async {
    try {
      await HomeWidget.saveWidgetData<bool>(_tipDismissedKey, true);
    } catch (e) {
      debugPrint('Widget tip dismiss failed: $e');
    }
  }
}
