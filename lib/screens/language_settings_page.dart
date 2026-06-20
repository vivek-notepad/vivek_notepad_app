import 'package:flutter/material.dart';
import 'package:simple_notepad/l10n/app_localizations.dart';
import '../services/locale_service.dart';

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final current = LocaleService.instance.locale;

    final options = <({Locale? locale, String label})>[
      (locale: null, label: l10n.systemDefault),
      (locale: const Locale('en'), label: l10n.english),
      (locale: const Locale('hi'), label: l10n.hindi),
      (locale: const Locale('es'), label: l10n.spanish),
      (locale: const Locale('fr'), label: l10n.french),
      (locale: const Locale('id'), label: l10n.indonesian),
      (locale: const Locale('pt', 'BR'), label: l10n.brazilianPortuguese),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.selectLanguage,
          style: const TextStyle(color: Colors.indigo),
        ),
      ),
      body: ListView.separated(
        itemCount: options.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final option = options[index];
          final selected = LocaleService.localesMatch(option.locale, current);

          return ListTile(
            title: Text(option.label),
            trailing: selected
                ? const Icon(Icons.check, color: Colors.indigo)
                : null,
            onTap: () async {
              if (option.locale == null) {
                await LocaleService.instance.clearLocale();
              } else {
                await LocaleService.instance.setLocale(option.locale!);
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.languageChanged)),
                );
                Navigator.pop(context);
              }
            },
          );
        },
      ),
    );
  }
}
