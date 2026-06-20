import 'package:flutter/material.dart';
import 'package:simple_notepad/l10n/app_localizations.dart';
import '../services/secure_storage_service.dart';
import '../utils/security_questions.dart';

class SecuritySetupPage extends StatefulWidget {
  const SecuritySetupPage({super.key});

  @override
  State<SecuritySetupPage> createState() => _SecuritySetupPageState();
}

class _SecuritySetupPageState extends State<SecuritySetupPage> {
  final SecureStorageService _secureStorage = SecureStorageService();
  final TextEditingController _answerController = TextEditingController();
  String? _selectedQuestion;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.securitySetup),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.setUpSecurityQuestion,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(l10n.selectSecurityQuestionPrompt),
            DropdownButtonFormField<String>(
              value: _selectedQuestion,
              hint: Text(l10n.selectSecurityQuestion),
              items: SecurityQuestions.keys.map((question) {
                return DropdownMenuItem(
                  value: question,
                  child: Text(SecurityQuestions.label(l10n, question)),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedQuestion = value),
            ),
            const SizedBox(height: 20),
            if (_selectedQuestion != null) ...[
              Text(SecurityQuestions.label(l10n, _selectedQuestion!)),
              const SizedBox(height: 10),
              TextField(
                controller: _answerController,
                decoration: InputDecoration(
                  labelText: l10n.answer,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveSecuritySetup,
                child: Text(l10n.saveSecuritySetup),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _saveSecuritySetup() async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedQuestion == null || _answerController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseSelectQuestionAndAnswer)),
      );
      return;
    }

    await _secureStorage.setSecurityQuestion(_selectedQuestion!, _answerController.text);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.securitySetupCompleted)),
    );
  }
}