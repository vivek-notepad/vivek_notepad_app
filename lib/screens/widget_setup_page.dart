import 'package:flutter/material.dart';
import 'package:simple_notepad/l10n/app_localizations.dart';
import '../services/widget_service.dart';

class WidgetSetupPage extends StatefulWidget {
  const WidgetSetupPage({super.key});

  @override
  State<WidgetSetupPage> createState() => _WidgetSetupPageState();
}

class _WidgetSetupPageState extends State<WidgetSetupPage> {
  bool _loading = true;
  bool _pinSupported = false;
  bool _widgetInstalled = false;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final pinSupported = await WidgetService.instance.isPinWidgetSupported();
      final installed = await WidgetService.instance.hasInstalledWidget();
      if (!mounted) return;
      setState(() {
        _pinSupported = pinSupported;
        _widgetInstalled = installed;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.couldNotLoadWidgetStatus('$e'))),
      );
    }
  }

  Future<void> _addWidget() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      if (_pinSupported) {
        final pinned = await WidgetService.instance.requestPinWidget();
        await WidgetService.instance.dismissHomeTip();
        if (!mounted) return;
        if (pinned) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.confirmAddWidget)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.couldNotOpenWidgetPicker)),
          );
        }
        await Future.delayed(const Duration(seconds: 1));
        await _loadStatus();
        return;
      }

      if (!mounted) return;
      _showManualStepsDialog();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.couldNotAddWidget('$e'))),
      );
    }
  }

  Future<void> _refreshWidget() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _refreshing = true);
    try {
      final refreshed = await WidgetService.instance.refreshWidget();
      if (!mounted) return;
      setState(() => _refreshing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            refreshed
                ? l10n.widgetRefreshed
                : l10n.couldNotRefreshWidgetRetry,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _refreshing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.couldNotRefreshWidget('$e'))),
      );
    }
  }

  void _showManualStepsDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addWidgetManually),
        content: Text(l10n.widgetManualDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.gotIt),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.homeScreenWidget,
          style: TextStyle(color: Colors.indigo),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.widgets,
                                color: Colors.indigo,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.seeNotesOnHomeScreen,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(l10n.widgetDescription),
                        if (_widgetInstalled) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  l10n.widgetInstalled,
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _addWidget,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.add_to_home_screen),
                    label: Text(
                      _pinSupported
                          ? l10n.addWidgetToHomeScreen
                          : l10n.showHowToAddWidget,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _refreshing ? null : _refreshWidget,
                    icon: _refreshing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(l10n.refreshWidgetNow),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.howToAddManually,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _step(1, l10n.widgetStep1),
                _step(2, l10n.widgetStep2),
                _step(3, l10n.widgetStep3),
                _step(4, l10n.widgetStep4),
                _step(5, l10n.widgetStep5),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.widgetOldDataTip,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _step(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: Colors.indigo,
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}
