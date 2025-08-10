import 'package:flutter/material.dart';
import '../services/secure_storage_service.dart';

class SecuritySetupPage extends StatefulWidget {
  const SecuritySetupPage({super.key});

  @override
  State<SecuritySetupPage> createState() => _SecuritySetupPageState();
}

class _SecuritySetupPageState extends State<SecuritySetupPage> {
  final SecureStorageService _secureStorage = SecureStorageService();
  final TextEditingController _answerController = TextEditingController();
  String? _selectedQuestion;
  final List<String> _securityQuestions = [
    "What is your date of birth?",
    "What is your favorite food?",
    "Which is your favorite place?"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Setup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set up security question',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text('Select a security question:'),
            DropdownButtonFormField<String>(
              value: _selectedQuestion,
              hint: const Text('Select security question'),
              items: _securityQuestions.map((question) {
                return DropdownMenuItem(
                  value: question,
                  child: Text(question),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedQuestion = value),
            ),
            const SizedBox(height: 20),
            if (_selectedQuestion != null) ...[
              Text(_selectedQuestion!),
              const SizedBox(height: 10),
              TextField(
                controller: _answerController,
                decoration: const InputDecoration(
                  labelText: 'Answer',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveSecuritySetup,
                child: const Text('Save Security Setup'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _saveSecuritySetup() async {
    if (_selectedQuestion == null || _answerController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a question and provide an answer')),
      );
      return;
    }

    await _secureStorage.setSecurityQuestion(_selectedQuestion!, _answerController.text);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Security setup completed successfully')),
    );
  }
}