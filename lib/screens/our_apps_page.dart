import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/our_apps.dart';
import '../models/our_app.dart';

class OurAppsPage extends StatelessWidget {
  const OurAppsPage({super.key});

  Future<void> _openPlayStore(BuildContext context, OurApp app) async {
    final marketUri = Uri.parse('market://details?id=${app.packageId}');
    final webUri = Uri.parse(app.playStoreUrl);

    if (await canLaunchUrl(marketUri)) {
      await launchUrl(marketUri, mode: LaunchMode.externalApplication);
      return;
    }

    if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
      return;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Play Store')),
      );
    }
  }

  Widget _buildAppIcon(OurApp app) {
    if (app.iconAsset != null && app.iconAsset!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          app.iconAsset!,
          width: 56,
          height: 56,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _defaultAppIcon(app.name),
        ),
      );
    }

    if (app.iconUrl != null && app.iconUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          app.iconUrl!,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _defaultAppIcon(app.name),
        ),
      );
    }
    return _defaultAppIcon(app.name);
  }

  Widget _defaultAppIcon(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'A';
    return CircleAvatar(
      radius: 28,
      backgroundColor: Colors.indigo.shade100,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.indigo.shade700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Our New Apps', style: TextStyle(color: Colors.indigo)),
      ),
      body: ourApps.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'More apps coming soon.\nCheck back later!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: ourApps.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final app = ourApps[index];
                return Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        _buildAppIcon(app),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                app.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (app.description.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  app.description,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _openPlayStore(context, app),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Install'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
