import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _secureStorage = const FlutterSecureStorage();

  // Store password
  Future<void> setPassword(String password) async {
    await _secureStorage.write(key: 'app_password', value: password);
  }

  // Check if password is set
  Future<bool> hasPassword() async {
    final password = await _secureStorage.read(key: 'app_password');
    return password != null && password.isNotEmpty;
  }

  // Verify password
  Future<bool> verifyPassword(String password) async {
    final storedPassword = await _secureStorage.read(key: 'app_password');
    return storedPassword == password;
  }

  // Store security question and answer
  Future<void> setSecurityQuestion(String question, String answer) async {
    await _secureStorage.write(key: 'security_question', value: question);
    await _secureStorage.write(key: 'security_answer', value: answer);
    await _secureStorage.write(key: 'security_setup', value: 'true');
  }

  // Get security question
  Future<String?> getSecurityQuestion() async {
    return await _secureStorage.read(key: 'security_question');
  }

  // Verify security answer
  Future<bool> verifySecurityAnswer(String answer) async {
    final storedAnswer = await _secureStorage.read(key: 'security_answer');
    return storedAnswer?.toLowerCase() == answer.toLowerCase();
  }

  // Reset password
  Future<void> resetPassword(String newPassword) async {
    await _secureStorage.write(key: 'app_password', value: newPassword);
  }

  // Store note-specific password
  Future<void> setNotePassword(String noteId, String password) async {
    await _secureStorage.write(key: 'note_password_$noteId', value: password);
  }

  // Get note-specific password
  Future<String?> getNotePassword(String noteId) async {
    return await _secureStorage.read(key: 'note_password_$noteId');
  }

  // Delete note-specific password
  Future<void> deleteNotePassword(String noteId) async {
    await _secureStorage.delete(key: 'note_password_$noteId');
  }
}