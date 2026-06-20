import 'package:flutter/material.dart';
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
        SnackBar(content: Text('Could not load widget status: $e')),
      );
    }
  }

  Future<void> _addWidget() async {
    try {
      if (_pinSupported) {
        final pinned = await WidgetService.instance.requestPinWidget();
        await WidgetService.instance.dismissHomeTip();
        if (!mounted) return;
        if (pinned) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Confirm adding the widget when your phone asks.',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open widget picker. Use manual steps below.'),
            ),
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
        SnackBar(content: Text('Could not add widget: $e')),
      );
    }
  }

  Future<void> _refreshWidget() async {
    setState(() => _refreshing = true);
    try {
      final refreshed = await WidgetService.instance.refreshWidget();
      if (!mounted) return;
      setState(() => _refreshing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            refreshed
                ? 'Home screen widget refreshed'
                : 'Could not refresh widget. Open the app and try again.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _refreshing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not refresh widget: $e')),
      );
    }
  }

  void _showManualStepsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add widget manually'),
        content: const Text(
          '1. Go to your phone home screen\n'
          '2. Long-press on empty space\n'
          '3. Tap Widgets\n'
          '4. Find "Secure Notepad Notes"\n'
          '5. Drag it to your home screen',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home Screen Widget',
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
                            const Expanded(
                              child: Text(
                                'See your notes on your home screen',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'The widget shows your 5 most recent notes and opens '
                          'the app when you tap it. It updates automatically '
                          'when you add or edit notes.',
                        ),
                        if (_widgetInstalled) ...[
                          const SizedBox(height: 12),
                          const Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Widget is on your home screen',
                                  style: TextStyle(
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
                          ? 'Add Widget to Home Screen'
                          : 'Show How to Add Widget',
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
                    label: const Text('Refresh Widget Now'),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'How to add manually',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _step(1, 'Go to your phone home screen'),
                _step(2, 'Long-press on empty space'),
                _step(3, 'Tap Widgets'),
                _step(4, 'Find "Secure Notepad Notes"'),
                _step(5, 'Drag it to your home screen'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'If the widget shows old data, open the app once or '
                          'tap "Refresh Widget Now" above.',
                          style: TextStyle(fontSize: 13),
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
